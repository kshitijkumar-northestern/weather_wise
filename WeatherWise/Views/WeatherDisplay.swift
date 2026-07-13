//
//  WeatherDisplay.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import SwiftUI

struct WeatherDisplay: View {
    let weather: WeatherModel
    let meetsCriteria: Bool
    let secondsUntilNextCheck: Int

    var formattedTimeRemaining: String {
        let minutes = secondsUntilNextCheck / 60
        let seconds = secondsUntilNextCheck % 60
        if minutes > 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        return "\(seconds)s"
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
                Image(systemName: weatherIcon(for: weather.condition))
                    .font(.system(size: 60))
                Text("\(Int(weather.temperature))°F")
                    .font(.system(size: 50))
            }

            Label(
                meetsCriteria ? "Ideal for outdoor activities" : "Not ideal yet",
                systemImage: meetsCriteria ? "checkmark.circle.fill" : "cloud.sun"
            )
            .foregroundStyle(meetsCriteria ? .green : .secondary)

            VStack(alignment: .leading, spacing: 8) {
                WeatherInfoRow(icon: "humidity", label: "Humidity", value: "\(weather.humidity)%")
                WeatherInfoRow(
                    icon: "wind",
                    label: "Wind Speed",
                    value: "\(String(format: "%.1f", weather.windSpeed)) mph"
                )
            }

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
    }

    private func weatherIcon(for condition: String) -> String {
        let lower = condition.lowercased()
        if lower.contains("rain") { return "cloud.rain" }
        if lower.contains("cloud") { return "cloud" }
        if lower.contains("snow") { return "snow" }
        if lower.contains("thunder") { return "cloud.bolt" }
        if lower.contains("fog") { return "cloud.fog" }
        if lower.contains("wind") { return "wind" }
        return "sun.max"
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
