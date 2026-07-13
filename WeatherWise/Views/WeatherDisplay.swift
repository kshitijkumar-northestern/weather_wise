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
            // Hero card
            VStack(alignment: .leading, spacing: 12) {
                Text(weather.locationName)
                    .font(.title2.weight(.semibold))

                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: weatherIcon(for: weather.condition))
                        .font(.system(size: 58))
                        .symbolRenderingMode(.hierarchical)
                    Text("\(Int(weather.temperature))°F")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Spacer()
                }

                Label(
                    meetsCriteria ? "Ideal for outdoor activities" : "Not ideal yet",
                    systemImage: meetsCriteria ? "checkmark.circle.fill" : "cloud.sun"
                )
                .font(.subheadline.weight(.medium))
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .wwGlassCapsule(
                    tint: meetsCriteria ? WWGlassTint.good : nil,
                    interactive: false
                )
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .wwGlassCard(tint: WWGlassTint.hero, cornerRadius: 30)

            // Detail chips
            WWGlassContainer(spacing: 20) {
                HStack(spacing: 12) {
                    MetricChip(icon: "humidity", label: "Humidity", value: "\(weather.humidity)%")
                    MetricChip(
                        icon: "wind",
                        label: "Wind",
                        value: "\(String(format: "%.1f", weather.windSpeed)) mph"
                    )
                }
            }

            // Countdown
            HStack {
                Image(systemName: "clock")
                Text("Next update in:")
                Text(formattedTimeRemaining)
                    .bold()
                    .monospacedDigit()
            }
            .font(.subheadline)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .wwGlassCard(cornerRadius: 16)
        }
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

struct MetricChip: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
            Text(value)
                .font(.headline)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .wwGlassCard(cornerRadius: 18, interactive: true)
    }
}
