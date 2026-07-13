//
//  HistoryView.swift
//  WeatherWise
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    var body: some View {
        ZStack {
            SkyBackground(condition: viewModel.currentWeather?.condition)

            if viewModel.history.isEmpty {
                ContentUnavailableView(
                    "No checks yet",
                    systemImage: "clock",
                    description: Text("Weather evaluations will appear here after the app runs a check.")
                )
                .padding(28)
                .wwGlassCard()
                .padding()
            } else {
                ScrollView {
                    WWGlassContainer(spacing: 20) {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.history) { record in
                                HistoryRow(record: record)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("History")
        .toolbar {
            if !viewModel.history.isEmpty {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Clear", role: .destructive) {
                        viewModel.clearHistory()
                    }
                }
            }
        }
    }
}

struct HistoryRow: View {
    let record: WeatherCheckRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.locationName)
                    .font(.headline)
                Spacer()
                if let latitude = record.latitude, let longitude = record.longitude {
                    DirectionsMenu(latitude: latitude, longitude: longitude, compact: true)
                }
                Image(systemName: record.metCriteria ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(record.metCriteria ? .green : .secondary)
            }
            Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(
                "\(Int(record.temperature))°F · \(record.humidity)% · \(String(format: "%.1f", record.windSpeed)) mph · \(record.condition)"
            )
            .font(.subheadline)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .wwGlassCard(
            tint: record.metCriteria ? WWGlassTint.good : nil,
            cornerRadius: 18
        )
    }
}
