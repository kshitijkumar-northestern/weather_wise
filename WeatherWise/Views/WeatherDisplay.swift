//
//  WeatherDisplay.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import SwiftUI

struct WeatherDisplay: View {
    let weather: WeatherModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Weather")
                .font(.largeTitle)
                .bold()
            
            Text(weather.locationName)
                .font(.title2)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: getWeatherIcon())
                    .font(.system(size: 60))
                Text("\(Int(weather.temperature))°C")
                    .font(.system(size: 50))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                WeatherInfoRow(icon: "humidity", label: "Humidity", value: "\(weather.humidity)%")
                WeatherInfoRow(icon: "wind", label: "Wind Speed", value: "\(String(format: "%.1f", weather.windSpeed)) km/h")
            }
            
            if weather.isGoodWeather {
                Text("Perfect weather to go outside!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func getWeatherIcon() -> String {
        switch weather.condition.lowercased() {
        case _ where weather.condition.contains("rain"):
            return "cloud.rain"
        case _ where weather.condition.contains("cloud"):
            return "cloud"
        case _ where weather.condition.contains("snow"):
            return "snow"
        case _ where weather.condition.contains("thunder"):
            return "cloud.bolt"
        case _ where weather.condition.contains("fog"):
            return "cloud.fog"
        case _ where weather.condition.contains("wind"):
            return "wind"
        default:
            return "sun.max"
        }
    }
}

struct WeatherInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(label)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct LocationPermissionView: View {
    let errorMessage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(errorMessage)
                .multilineTextAlignment(.center)
            
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text(message)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
