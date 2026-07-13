//
//  ServiceProtocols.swift
//  WeatherWise
//

import CoreLocation
import Foundation

protocol WeatherFetching {
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel
    func fetchForecast(latitude: Double, longitude: Double) async throws -> [ForecastSlot]
}

protocol Locating: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)? { get set }
    func requestWhenInUseAuthorization()
    func currentCoordinate() async throws -> CLLocationCoordinate2D
}

protocol Notifying {
    func requestAuthorization()
    func sendNotification(title: String, body: String)
}

protocol CriteriaPersisting {
    func loadCriteria() -> WeatherCriteria
    func saveCriteria(_ criteria: WeatherCriteria)
}

protocol HistoryPersisting {
    func loadHistory() -> [WeatherCheckRecord]
    func saveHistory(_ records: [WeatherCheckRecord])
}

enum LocationStatus: Equatable {
    case unknown
    case noPermission
    case permissionGranted
    case error
}

enum WeatherWiseError: LocalizedError, Equatable {
    case missingAPIKey
    case invalidURL
    case locationUnavailable
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is not configured. Copy Secrets.example.plist to Secrets.plist and add your OpenWeatherMap API key."
        case .invalidURL:
            return "Could not build a valid weather request URL."
        case .locationUnavailable:
            return "Unable to determine your current location."
        case .decodingFailed:
            return "Weather data from the server could not be understood."
        }
    }
}
