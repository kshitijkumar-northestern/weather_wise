//
//  WeatherService.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//


import Foundation
import CoreLocation

class WeatherService: ObservableObject {
    // Replace with your actual OpenWeather API key
    private let apiKey = "48460fe7b8a39ff8396bfc568493212a"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    @Published var currentWeather: WeatherResponse?
    @Published var error: Error?
    
    func fetchWeather(for location: CLLocation) async throws -> WeatherResponse {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        guard let url = URL(string: "\(baseURL)?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        print("Fetching weather from URL: \(url)") // Debug print
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Server error: \(String(data: data, encoding: .utf8) ?? "No error message")") // Debug print
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let weather = try decoder.decode(WeatherResponse.self, from: data)
        return weather
    }
}
