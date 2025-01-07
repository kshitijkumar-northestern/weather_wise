//
//  WeatherDisplay.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import SwiftUI

struct WeatherDisplay: View {
    let weather: WeatherModel
    @State private var timeRemaining: Int
    let timerInterval: Int
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Initialize with different intervals for testing/production
    init(weather: WeatherModel, isTestMode: Bool = false) {
        self.weather = weather
        // Set interval: 30 seconds for testing, 30 minutes for production
        self.timerInterval = isTestMode ? 30 : 1800
        // Initialize timeRemaining with the interval
        _timeRemaining = State(initialValue: isTestMode ? 30 : 1800)
    }
    
    var formattedTimeRemaining: String {
        if timerInterval <= 60 {
            // For test mode: show seconds only
            return "\(timeRemaining)s"
        } else {
            // For production: show minutes and seconds
            let minutes = timeRemaining / 60
            let seconds = timeRemaining % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Weather")
                .font(.largeTitle)
                .bold()
            
            Text(weather.locationName)
                .font(.title2)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: getWeatherIcon(condition: weather.condition))
                    .font(.system(size: 60))
                Text("\(Int(weather.temperature))°C")
                    .font(.system(size: 50))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                WeatherInfoRow(icon: "humidity", label: "Humidity", value: "\(weather.humidity)%")
                WeatherInfoRow(icon: "wind", label: "Wind Speed", value: "\(String(format: "%.1f", weather.windSpeed)) km/h")
            }
            
            // Countdown Timer
            HStack {
                Image(systemName: "clock")
                Text("Next update in:")
                Text(formattedTimeRemaining)
                    .bold()
                    .monospacedDigit()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timeRemaining = timerInterval
            }
        }
    }
    
    private func getWeatherIcon(condition: String) -> String {
        switch condition.lowercased() {
        case _ where condition.contains("rain"):
            return "cloud.rain"
        case _ where condition.contains("cloud"):
            return "cloud"
        case _ where condition.contains("snow"):
            return "snow"
        case _ where condition.contains("thunder"):
            return "cloud.bolt"
        case _ where condition.contains("fog"):
            return "cloud.fog"
        case _ where condition.contains("wind"):
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
