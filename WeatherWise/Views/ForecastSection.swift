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
                    .padding(.leading, 4)

                ScrollView(.horizontal, showsIndicators: false) {
                    WWGlassContainer(spacing: 24) {
                        HStack(spacing: 12) {
                            ForEach(upcomingSlots) { slot in
                                ForecastSlotCard(slot: slot, isGood: slot.meets(criteria))
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 2)
                    }
                }
            }
        }
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
            .font(.subheadline.weight(.semibold))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .wwGlassCard(tint: WWGlassTint.good, cornerRadius: 18)
        } else if !forecast.isEmpty {
            Label("No ideal weather window in the forecast", systemImage: "cloud")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .wwGlassCard(cornerRadius: 18)
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
                .symbolRenderingMode(.hierarchical)
            Text("\(Int(slot.temperature))°")
                .font(.headline)
                .monospacedDigit()
            Circle()
                .fill(isGood ? Color.green : Color.white.opacity(0.35))
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .wwGlassCard(
            tint: isGood ? WWGlassTint.good : nil,
            cornerRadius: 16,
            interactive: true
        )
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
