//
//  ForecastSection.swift
//  WeatherWise
//

import SwiftUI

/// Upcoming forecast slots plus a banner for the next good-weather window.
struct ForecastSection: View {
    let forecast: [ForecastSlot]
    let nextGoodWindow: GoodWeatherWindow?
    let criteria: WeatherCriteria

    /// Show roughly the next 24 hours (eight 3-hour slots).
    private var upcomingSlots: [ForecastSlot] {
        Array(forecast.prefix(8))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            windowBanner

            if !upcomingSlots.isEmpty {
                Text("Next 24 hours")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(upcomingSlots) { slot in
                            ForecastSlotCard(slot: slot, isGood: slot.meets(criteria))
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var windowBanner: some View {
        if let window = nextGoodWindow {
            Label {
                Text("Good weather \(window.start.formatted(date: .omitted, time: .shortened)) – \(window.end.formatted(date: .omitted, time: .shortened)) \(relativeDay(for: window.start))")
            } icon: {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.yellow)
            }
            .font(.subheadline.weight(.medium))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.15))
            .cornerRadius(10)
        } else if !forecast.isEmpty {
            Label("No ideal weather window in the forecast", systemImage: "cloud")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }

    private func relativeDay(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "today" }
        if Calendar.current.isDateInTomorrow(date) { return "tomorrow" }
        return date.formatted(.dateTime.weekday(.wide))
    }
}

struct ForecastSlotCard: View {
    let slot: ForecastSlot
    let isGood: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(slot.date.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            Image(systemName: icon(for: slot.condition))
                .font(.title3)
            Text("\(Int(slot.temperature))°")
                .font(.headline)
            Circle()
                .fill(isGood ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
        }
        .padding(10)
        .background(Color.blue.opacity(0.08))
        .cornerRadius(10)
    }

    private func icon(for condition: String) -> String {
        let lower = condition.lowercased()
        if lower.contains("rain") { return "cloud.rain" }
        if lower.contains("cloud") { return "cloud" }
        if lower.contains("snow") { return "snow" }
        if lower.contains("thunder") { return "cloud.bolt" }
        if lower.contains("fog") { return "cloud.fog" }
        return "sun.max"
    }
}
