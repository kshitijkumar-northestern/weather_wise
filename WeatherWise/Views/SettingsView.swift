//
//  SettingsView.swift
//  WeatherWise
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var draft: WeatherCriteria = .default

    var body: some View {
        Form {
            Section("Ideal temperature (°F)") {
                Stepper(
                    value: $draft.minimumTemperature,
                    in: -20...120,
                    step: 1
                ) {
                    Text("Minimum: \(Int(draft.minimumTemperature))°F")
                }
                Stepper(
                    value: $draft.maximumTemperature,
                    in: -20...120,
                    step: 1
                ) {
                    Text("Maximum: \(Int(draft.maximumTemperature))°F")
                }
            }

            Section("Humidity & wind") {
                Stepper(value: $draft.maximumHumidity, in: 1...100, step: 1) {
                    Text("Max humidity: \(draft.maximumHumidity)%")
                }
                Stepper(value: $draft.maximumWindSpeed, in: 1...80, step: 1) {
                    Text("Max wind: \(Int(draft.maximumWindSpeed)) mph")
                }
            }

            Section("Check interval") {
                Picker("Interval", selection: $draft.checkInterval) {
                    Text("1 min (testing)").tag(60.0)
                    Text("15 min").tag(900.0)
                    Text("30 min").tag(1800.0)
                    Text("60 min").tag(3600.0)
                }
            }

            Section {
                Button("Reset to defaults") {
                    draft = .default
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            draft = viewModel.criteria
        }
        .onDisappear {
            viewModel.saveCriteria(draft)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.saveCriteria(draft)
                }
            }
        }
    }
}
