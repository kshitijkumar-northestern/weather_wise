//
//  WeatherWiseTests.swift
//  WeatherWiseTests
//
//  Created by Kshitij Kumar on 1/6/25.
//

import CoreLocation
import Foundation
import Testing
@testable import WeatherWise

struct WeatherCriteriaTests {
    @Test func defaultCriteriaMatchDocumentedThresholds() {
        let criteria = WeatherCriteria.default
        #expect(criteria.minimumTemperature == 65)
        #expect(criteria.maximumTemperature == 77)
        #expect(criteria.maximumHumidity == 70)
        #expect(criteria.maximumWindSpeed == 12)
        #expect(criteria.checkInterval == 1800)
    }

    @Test func normalizeSwapsInvertedTemperatureRange() {
        var criteria = WeatherCriteria(
            minimumTemperature: 80,
            maximumTemperature: 60,
            maximumHumidity: 70,
            maximumWindSpeed: 12,
            checkInterval: 1800
        )
        criteria.normalize()
        #expect(criteria.minimumTemperature == 60)
        #expect(criteria.maximumTemperature == 80)
    }

    @Test func weatherMeetsCriteriaAtBoundaries() {
        let criteria = WeatherCriteria.default
        let ideal = WeatherModel(
            temperature: 70,
            condition: "Clear",
            humidity: 50,
            windSpeed: 5,
            locationName: "Boston, US"
        )
        #expect(ideal.meets(criteria))

        let tooCold = WeatherModel(
            temperature: 64.9,
            condition: "Clear",
            humidity: 50,
            windSpeed: 5,
            locationName: "Boston, US"
        )
        #expect(!tooCold.meets(criteria))

        let tooHumid = WeatherModel(
            temperature: 70,
            condition: "Clear",
            humidity: 70,
            windSpeed: 5,
            locationName: "Boston, US"
        )
        #expect(!tooHumid.meets(criteria))

        let tooWindy = WeatherModel(
            temperature: 70,
            condition: "Clear",
            humidity: 50,
            windSpeed: 12,
            locationName: "Boston, US"
        )
        #expect(!tooWindy.meets(criteria))
    }
}

struct WeatherDecodingTests {
    @Test func decodesOpenWeatherResponseFixture() throws {
        let json = """
        {
          "weather": [{"main": "Clouds", "description": "scattered clouds"}],
          "main": {"temp": 72.5, "humidity": 55},
          "wind": {"speed": 8.2},
          "name": "Boston",
          "sys": {"country": "US"}
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(OpenWeatherResponse.self, from: json)
        let model = WeatherModel.from(response: response)

        #expect(model.temperature == 72.5)
        #expect(model.condition == "Clouds")
        #expect(model.humidity == 55)
        #expect(model.windSpeed == 8.2)
        #expect(model.locationName == "Boston, US")
    }
}

struct PersistenceTests {
    @Test func criteriaStoreRoundTrips() {
        let suiteName = "weatherwise.tests.criteria.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = CriteriaStore(defaults: defaults)
        var criteria = WeatherCriteria.default
        criteria.minimumTemperature = 68
        criteria.maximumHumidity = 60
        store.saveCriteria(criteria)

        let loaded = store.loadCriteria()
        #expect(loaded.minimumTemperature == 68)
        #expect(loaded.maximumHumidity == 60)
    }

    @Test func historyStoreCapsAndOrdersNewestFirst() {
        let suiteName = "weatherwise.tests.history.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = HistoryStore(defaults: defaults, maxRecords: 3)
        var records: [WeatherCheckRecord] = []
        for index in 0..<5 {
            let record = WeatherCheckRecord(
                timestamp: Date(timeIntervalSince1970: TimeInterval(index)),
                temperature: Double(60 + index),
                humidity: 40,
                windSpeed: 5.0,
                condition: "Clear",
                locationName: "Test",
                metCriteria: index.isMultiple(of: 2)
            )
            records.append(record)
        }
        store.saveHistory(records)
        let loaded = store.loadHistory()
        #expect(loaded.count == 3)
        #expect(loaded.first?.temperature == 64)
    }
}

@MainActor
struct WeatherViewModelTests {
    @Test func missingAPIKeySurfacesConfigurationError() {
        let viewModel = WeatherViewModel(
            weatherFetcher: MockWeatherFetcher(result: .failure(WeatherWiseError.missingAPIKey)),
            locationProvider: MockLocationProvider(status: .authorizedWhenInUse),
            notifier: MockNotifier(),
            criteriaStore: InMemoryCriteriaStore(),
            historyStore: InMemoryHistoryStore(),
            apiKey: nil
        )

        #expect(viewModel.locationStatus == .error)
        #expect(viewModel.errorMessage?.contains("API key") == true)
    }

    @Test func successfulRefreshUpdatesWeatherAndHistory() async {
        let weather = WeatherModel(
            temperature: 70,
            condition: "Clear",
            humidity: 40,
            windSpeed: 4,
            locationName: "Boston, US"
        )
        let historyStore = InMemoryHistoryStore()
        let viewModel = WeatherViewModel(
            weatherFetcher: MockWeatherFetcher(result: .success(weather)),
            locationProvider: MockLocationProvider(status: .authorizedWhenInUse),
            notifier: MockNotifier(),
            criteriaStore: InMemoryCriteriaStore(),
            historyStore: historyStore,
            apiKey: "test-key"
        )

        let success = await viewModel.performWeatherCheck(sendNotificationIfIdeal: false)
        #expect(success)
        #expect(viewModel.currentWeather?.locationName == "Boston, US")
        #expect(viewModel.history.count == 1)
        #expect(viewModel.history.first?.metCriteria == true)
    }

    @Test func deniedLocationSetsNoPermissionStatus() {
        let viewModel = WeatherViewModel(
            weatherFetcher: MockWeatherFetcher(result: .failure(WeatherWiseError.locationUnavailable)),
            locationProvider: MockLocationProvider(status: .denied),
            notifier: MockNotifier(),
            criteriaStore: InMemoryCriteriaStore(),
            historyStore: InMemoryHistoryStore(),
            apiKey: "test-key"
        )

        #expect(viewModel.locationStatus == .noPermission)
    }
}

// MARK: - Test doubles

final class MockWeatherFetcher: WeatherFetching {
    let result: Result<WeatherModel, Error>

    init(result: Result<WeatherModel, Error>) {
        self.result = result
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        try result.get()
    }
}

final class MockLocationProvider: Locating {
    var authorizationStatus: CLAuthorizationStatus
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
    var coordinate = CLLocationCoordinate2D(latitude: 42.36, longitude: -71.06)

    init(status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }

    func requestWhenInUseAuthorization() {}

    func currentCoordinate() async throws -> CLLocationCoordinate2D {
        coordinate
    }
}

final class MockNotifier: Notifying {
    var sentTitles: [String] = []

    func requestAuthorization() {}

    func sendNotification(title: String, body: String) {
        sentTitles.append(title)
    }
}

final class InMemoryCriteriaStore: CriteriaPersisting {
    var criteria: WeatherCriteria = .default

    func loadCriteria() -> WeatherCriteria { criteria }
    func saveCriteria(_ criteria: WeatherCriteria) { self.criteria = criteria }
}

final class InMemoryHistoryStore: HistoryPersisting {
    var records: [WeatherCheckRecord] = []

    func loadHistory() -> [WeatherCheckRecord] { records }
    func saveHistory(_ records: [WeatherCheckRecord]) { self.records = records }
}
