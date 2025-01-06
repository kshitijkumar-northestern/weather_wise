//
//  WeatherViewModel.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import Foundation
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var temperature: Double = 0.0
    @Published var condition: String = "Unknown"
    @Published var isGoodWeather: Bool = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherService()
    
    func updateWeather(for location: CLLocation) {
        Task {
            do {
                print("Updating weather for location: \(location)") // Debug print
                let weather = try await weatherService.fetchWeather(for: location)
                
                self.temperature = weather.main.temp
                self.condition = weather.weather.first?.main ?? "Unknown"
                self.isGoodWeather = isWeatherGoodForOutdoors(weather)
                self.errorMessage = nil
                
                print("Weather updated - Temp: \(self.temperature)°C, Condition: \(self.condition)") // Debug print
            } catch {
                print("Error fetching weather: \(error)") // Debug print
                self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
            }
        }
    }
    
    private func isWeatherGoodForOutdoors(_ weather: WeatherResponse) -> Bool {
        let goodTemperatureRange = (15.0...30.0)
        let goodWeatherIds = Set([800, 801]) // Clear sky and few clouds
        
        return goodTemperatureRange.contains(weather.main.temp) &&
               weather.weather.first.map { goodWeatherIds.contains($0.id) } ?? false
    }
}
