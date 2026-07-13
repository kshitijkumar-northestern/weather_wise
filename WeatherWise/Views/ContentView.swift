//
//  ContentView.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.locationStatus {
                case .unknown:
                    ProgressView("Checking location permissions...")
                case .noPermission:
                    LocationPermissionView(errorMessage: viewModel.errorMessage ?? "")
                case .error:
                    ErrorView(message: viewModel.errorMessage ?? "Something went wrong. Please try again.")
                case .permissionGranted:
                    if let weather = viewModel.currentWeather {
                        WeatherDisplay(
                            weather: weather,
                            meetsCriteria: weather.meets(viewModel.criteria),
                            secondsUntilNextCheck: viewModel.secondsUntilNextCheck
                        )
                    } else if let message = viewModel.errorMessage {
                        ErrorView(message: message)
                    } else {
                        ProgressView("Fetching weather data...")
                    }
                }
            }
            .padding()
            .navigationTitle("WeatherWise")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                    .accessibilityLabel("History")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .refreshable {
                _ = await viewModel.performWeatherCheck(sendNotificationIfIdeal: true)
            }
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
