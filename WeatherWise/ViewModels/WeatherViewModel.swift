//
//  WeatherViewModel.swift
//  WeatherWise
//

import CoreLocation
import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published private(set) var currentWeather: WeatherModel?
    @Published private(set) var lastCoordinate: CLLocationCoordinate2D?
    @Published private(set) var forecast: [ForecastSlot] = []
    @Published private(set) var nextGoodWindow: GoodWeatherWindow?
    @Published private(set) var locationStatus: LocationStatus = .unknown
    @Published private(set) var errorMessage: String?
    @Published var criteria: WeatherCriteria
    @Published private(set) var history: [WeatherCheckRecord] = []
    @Published private(set) var secondsUntilNextCheck: Int

    private let weatherFetcher: WeatherFetching
    private let locationProvider: Locating
    private let notifier: Notifying
    private let criteriaStore: CriteriaPersisting
    private let historyStore: HistoryPersisting
    private let hasAPIKey: Bool

    private var timer: Timer?
    private var isFirstCheck = true
    private var countdownTimer: Timer?

    init(
        weatherFetcher: WeatherFetching? = nil,
        locationProvider: Locating = LocationProvider(),
        notifier: Notifying = NotificationService.shared,
        criteriaStore: CriteriaPersisting = CriteriaStore(),
        historyStore: HistoryPersisting = HistoryStore(),
        apiKey: String? = SecretsLoader.openWeatherMapAPIKey()
    ) {
        let resolvedKey = apiKey ?? ""
        self.hasAPIKey = !resolvedKey.isEmpty
        self.weatherFetcher = weatherFetcher ?? WeatherAPIClient(apiKey: resolvedKey)
        self.locationProvider = locationProvider
        self.notifier = notifier
        self.criteriaStore = criteriaStore
        self.historyStore = historyStore
        let loaded = criteriaStore.loadCriteria()
        self.criteria = loaded
        self.secondsUntilNextCheck = Int(loaded.checkInterval)
        self.history = historyStore.loadHistory()

        self.locationProvider.onAuthorizationChange = { [weak self] status in
            Task { @MainActor in
                self?.handleAuthorization(status)
            }
        }

        if !hasAPIKey {
            errorMessage = WeatherWiseError.missingAPIKey.errorDescription
            locationStatus = .error
        } else {
            notifier.requestAuthorization()
            locationProvider.requestWhenInUseAuthorization()
            handleAuthorization(locationProvider.authorizationStatus)
        }
    }

    func startMonitoring() {
        guard hasAPIKey else { return }
        isFirstCheck = true
        restartTimers()
        Task { await refreshWeather(sendNotificationIfIdeal: false) }
        BackgroundWeatherScheduler.schedule(after: criteria.checkInterval)
    }

    func saveCriteria(_ updated: WeatherCriteria) {
        var normalized = updated
        normalized.normalize()
        criteria = normalized
        criteriaStore.saveCriteria(normalized)
        nextGoodWindow = GoodWeatherWindow.next(in: forecast, criteria: normalized)
        restartTimers()
        BackgroundWeatherScheduler.schedule(after: normalized.checkInterval)
    }

    func refreshNow() {
        Task { await refreshWeather(sendNotificationIfIdeal: true) }
    }

    func clearHistory() {
        history = []
        historyStore.saveHistory([])
    }

    /// Shared path for foreground and background evaluation.
    func performWeatherCheck(sendNotificationIfIdeal: Bool) async -> Bool {
        await refreshWeather(sendNotificationIfIdeal: sendNotificationIfIdeal)
        return currentWeather != nil
    }

    private func restartTimers() {
        timer?.invalidate()
        countdownTimer?.invalidate()
        secondsUntilNextCheck = Int(criteria.checkInterval)

        timer = Timer.scheduledTimer(withTimeInterval: criteria.checkInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshWeather(sendNotificationIfIdeal: true)
                self?.secondsUntilNextCheck = Int(self?.criteria.checkInterval ?? 1800)
                BackgroundWeatherScheduler.schedule(after: self?.criteria.checkInterval ?? 1800)
            }
        }

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.secondsUntilNextCheck > 0 {
                    self.secondsUntilNextCheck -= 1
                }
            }
        }
    }

    private func handleAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatus = .permissionGranted
        case .denied, .restricted:
            locationStatus = .noPermission
            errorMessage = "Please enable location access in Settings to see weather information."
        case .notDetermined:
            locationStatus = .unknown
        @unknown default:
            locationStatus = .error
            errorMessage = "Unexpected location authorization state."
        }
    }

    @discardableResult
    private func refreshWeather(sendNotificationIfIdeal: Bool) async -> Bool {
        guard hasAPIKey else { return false }

        let status = locationProvider.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            handleAuthorization(status)
            return false
        }

        do {
            let coordinate = try await locationProvider.currentCoordinate()
            let weather = try await weatherFetcher.fetchWeather(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            currentWeather = weather
            lastCoordinate = coordinate
            locationStatus = .permissionGranted
            errorMessage = nil

            // A forecast failure should not fail the whole check.
            if let slots = try? await weatherFetcher.fetchForecast(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ) {
                forecast = slots
                nextGoodWindow = GoodWeatherWindow.next(in: slots, criteria: criteria)
            }

            let met = weather.meets(criteria)
            let record = WeatherCheckRecord(
                weather: weather,
                metCriteria: met,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            history.insert(record, at: 0)
            historyStore.saveHistory(history)

            if sendNotificationIfIdeal {
                maybeNotify(weather: weather, metCriteria: met)
            } else if isFirstCheck {
                isFirstCheck = false
            }

            secondsUntilNextCheck = Int(criteria.checkInterval)
            return true
        } catch {
            errorMessage = error.localizedDescription
            if locationStatus == .permissionGranted {
                // Keep permission-granted UI but surface the fetch error.
            } else {
                locationStatus = .error
            }
            return false
        }
    }

    private func maybeNotify(weather: WeatherModel, metCriteria: Bool) {
        if isFirstCheck {
            isFirstCheck = false
            return
        }
        guard metCriteria else { return }
        guard !criteria.isQuietTime() else {
            print("Quiet hours active - notification suppressed")
            return
        }

        notifier.sendNotification(
            title: "Perfect Weather",
            body: """
            Time to go outside!
            Temperature: \(Int(weather.temperature))°F
            Humidity: \(weather.humidity)%
            Wind: \(String(format: "%.1f", weather.windSpeed)) mph
            Location: \(weather.locationName)
            Time: \(Date().formatted(date: .omitted, time: .shortened))
            """
        )
    }
}
