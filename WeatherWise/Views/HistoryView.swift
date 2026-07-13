//
//  HistoryView.swift
//  WeatherWise
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    var body: some View {
        List {
            if viewModel.history.isEmpty {
                ContentUnavailableView(
                    "No checks yet",
                    systemImage: "clock",
                    description: Text("Weather evaluations will appear here after the app runs a check.")
                )
            } else {
                ForEach(viewModel.history) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(record.locationName)
                                .font(.headline)
                            Spacer()
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
                    .padding(.vertical, 4)
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
