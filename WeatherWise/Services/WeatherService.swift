//
//  WeatherService.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import Foundation
import CoreLocation

class WeatherService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentWeather: WeatherModel?
    @Published var locationStatus: LocationStatus = .unknown
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private let apiKey = "48460fe7b8a39ff8396bfc568493212a"
    private var timer: Timer?
    
    enum LocationStatus {
        case unknown
        case noPermission
        case permissionGranted
        case error
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startPeriodicWeatherChecks() {
        print("🔄 Starting periodic weather checks")
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            print("⏰ Weather check timer fired")
            self?.locationManager.startUpdatingLocation()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(OpenWeatherResponse.self, from: data)
            
            return WeatherModel(
                temperature: response.main.temp,
                condition: response.weather.first?.main ?? "Unknown",
                humidity: response.main.humidity,
                windSpeed: response.wind.speed,
                locationName: "\(response.name), \(response.sys.country)"
            )
        } catch {
            print("❌ Weather decoding error: \(error)")
            throw error
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationStatus = .permissionGranted
                self.locationManager.startUpdatingLocation()
            case .denied, .restricted:
                self.locationStatus = .noPermission
                self.errorMessage = "Please enable location access in Settings to see weather information."
            case .notDetermined:
                self.locationStatus = .unknown
            @unknown default:
                self.locationStatus = .error
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        
        Task {
            do {
                let weather = try await fetchWeather(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                DispatchQueue.main.async {
                    self.currentWeather = weather
                    self.sendWeatherNotification(weather)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching weather data: \(error.localizedDescription)"
                    self.locationStatus = .error
                }
            }
        }
    }
    
    private func sendWeatherNotification(_ weather: WeatherModel) {
        print("🌤️ Sending weather notification for: \(weather.locationName)")
        NotificationManager.shared.sendNotification(
            title: "Weather Update",
            body: """
            Location: \(weather.locationName)
            Temperature: \(Int(weather.temperature))°C
            Humidity: \(weather.humidity)%
            Time: \(Date().formatted(date: .omitted, time: .shortened))
            """
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Location error: \(error.localizedDescription)"
            self.locationStatus = .error
        }
    }
}
