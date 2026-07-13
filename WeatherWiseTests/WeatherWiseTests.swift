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

struct QuietHoursTests {
    private func date(hour: Int) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 13
        components.hour = hour
        return Calendar.current.date(from: components)!
    }

    @Test func disabledQuietHoursNeverSuppress() {
        var criteria = WeatherCriteria.default
        criteria.quietHoursEnabled = false
        #expect(!criteria.isQuietTime(date(hour: 23)))
        #expect(!criteria.isQuietTime(date(hour: 3)))
    }

    @Test func wrappingRangeCoversLateNightAndEarlyMorning() {
        var criteria = WeatherCriteria.default
        criteria.quietHoursEnabled = true
        criteria.quietStartHour = 22
        criteria.quietEndHour = 7

        #expect(criteria.isQuietTime(date(hour: 23)))
        #expect(criteria.isQuietTime(date(hour: 3)))
        #expect(!criteria.isQuietTime(date(hour: 12)))
        #expect(!criteria.isQuietTime(date(hour: 21)))
        #expect(!criteria.isQuietTime(date(hour: 7)))
    }

    @Test func nonWrappingRangeWorks() {
        var criteria = WeatherCriteria.default
        criteria.quietHoursEnabled = true
        criteria.quietStartHour = 9
        criteria.quietEndHour = 17

        #expect(criteria.isQuietTime(date(hour: 12)))
        #expect(!criteria.isQuietTime(date(hour: 8)))
        #expect(!criteria.isQuietTime(date(hour: 17)))
    }

    @Test func legacyCriteriaWithoutQuietHoursStillDecodes() throws {
        let legacyJSON = """
        {
          "minimumTemperature": 60,
          "maximumTemperature": 80,
          "maximumHumidity": 65,
          "maximumWindSpeed": 10,
          "checkInterval": 900
        }
        """.data(using: .utf8)!

        let criteria = try JSONDecoder().decode(WeatherCriteria.self, from: legacyJSON)
        #expect(criteria.minimumTemperature == 60)
        #expect(criteria.quietHoursEnabled == false)
        #expect(criteria.quietStartHour == 22)
        #expect(criteria.quietEndHour == 7)
    }
}

struct ForecastTests {
    private func slot(hoursFromNow: Double, temperature: Double, base: Date) -> ForecastSlot {
        ForecastSlot(
            date: base.addingTimeInterval(hoursFromNow * 3600),
            temperature: temperature,
            humidity: 50,
            windSpeed: 5,
            condition: "Clear"
        )
    }

    @Test func decodesForecastResponseFixture() throws {
        let json = """
        {
          "list": [
            {
              "dt": 1752408000,
              "main": {"temp": 70.0, "humidity": 50},
              "wind": {"speed": 6.0},
              "weather": [{"main": "Clear", "description": "clear sky"}]
            },
            {
              "dt": 1752418800,
              "main": {"temp": 85.0, "humidity": 60},
              "wind": {"speed": 4.0},
              "weather": [{"main": "Clouds", "description": "few clouds"}]
            }
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ForecastResponse.self, from: json)
        let slots = ForecastSlot.from(response: response)

        #expect(slots.count == 2)
        #expect(slots[0].temperature == 70.0)
        #expect(slots[0].condition == "Clear")
        #expect(slots[1].condition == "Clouds")
        #expect(slots[0].date < slots[1].date)
    }

    @Test func nextGoodWindowFindsFirstContiguousRun() {
        let base = Date()
        let criteria = WeatherCriteria.default
        // Too hot, then two good slots, then too cold, then good again.
        let slots = [
            slot(hoursFromNow: 1, temperature: 90, base: base),
            slot(hoursFromNow: 4, temperature: 70, base: base),
            slot(hoursFromNow: 7, temperature: 72, base: base),
            slot(hoursFromNow: 10, temperature: 50, base: base),
            slot(hoursFromNow: 13, temperature: 70, base: base)
        ]

        let window = GoodWeatherWindow.next(in: slots, criteria: criteria, after: base)
        #expect(window != nil)
        #expect(window?.start == base.addingTimeInterval(4 * 3600))
        #expect(window?.end == base.addingTimeInterval(10 * 3600))
    }

    @Test func noWindowWhenNothingMatches() {
        let base = Date()
        let criteria = WeatherCriteria.default
        let slots = [
            slot(hoursFromNow: 1, temperature: 90, base: base),
            slot(hoursFromNow: 4, temperature: 95, base: base)
        ]

        #expect(GoodWeatherWindow.next(in: slots, criteria: criteria, after: base) == nil)
    }

    @Test func pastSlotsAreIgnored() {
        let base = Date()
        let criteria = WeatherCriteria.default
        let slots = [
            slot(hoursFromNow: -10, temperature: 70, base: base),
            slot(hoursFromNow: 3, temperature: 70, base: base)
        ]

        let window = GoodWeatherWindow.next(in: slots, criteria: criteria, after: base)
        #expect(window?.start == base.addingTimeInterval(3 * 3600))
    }
}

struct DirectionsBuilderTests {
    @Test func appleMapsURLContainsDestination() throws {
        let url = try #require(DirectionsBuilder.appleMaps(latitude: 42.36, longitude: -71.06))
        #expect(url.host() == "maps.apple.com")
        #expect(url.query()?.contains("daddr=42.36,-71.06") == true)
    }

    @Test func googleMapsAppURLUsesScheme() throws {
        let url = try #require(DirectionsBuilder.googleMapsApp(latitude: 42.36, longitude: -71.06))
        #expect(url.scheme == "comgooglemaps")
        #expect(url.absoluteString.contains("daddr=42.36,-71.06"))
    }

    @Test func googleMapsWebURLIsUniversal() throws {
        let url = try #require(DirectionsBuilder.googleMapsWeb(latitude: 42.36, longitude: -71.06))
        #expect(url.host() == "www.google.com")
        #expect(url.query()?.contains("api=1") == true)
        #expect(url.query()?.contains("destination=42.36,-71.06") == true)
    }
}

struct WeatherCheckRecordCompatibilityTests {
    @Test func legacyRecordWithoutCoordinatesDecodes() throws {
        let legacyJSON = """
        {
          "id": "00000000-0000-0000-0000-000000000001",
          "timestamp": 700000000,
          "temperature": 70,
          "humidity": 50,
          "windSpeed": 5,
          "condition": "Clear",
          "locationName": "Boston, US",
          "metCriteria": true
        }
        """.data(using: .utf8)!

        let record = try JSONDecoder().decode(WeatherCheckRecord.self, from: legacyJSON)
        #expect(record.latitude == nil)
        #expect(record.longitude == nil)
        #expect(record.locationName == "Boston, US")
    }

    @Test func recordRoundTripsCoordinates() throws {
        let record = WeatherCheckRecord(
            temperature: 70,
            humidity: 50,
            windSpeed: 5,
            condition: "Clear",
            locationName: "Boston, US",
            metCriteria: true,
            latitude: 42.36,
            longitude: -71.06
        )
        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(WeatherCheckRecord.self, from: data)
        #expect(decoded.latitude == 42.36)
        #expect(decoded.longitude == -71.06)
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
    var forecastSlots: [ForecastSlot] = []

    init(result: Result<WeatherModel, Error>) {
        self.result = result
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        try result.get()
    }

    func fetchForecast(latitude: Double, longitude: Double) async throws -> [ForecastSlot] {
        forecastSlots
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
