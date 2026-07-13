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
            ZStack {
                SkyBackground(condition: viewModel.currentWeather?.condition)

                Group {
                    switch viewModel.locationStatus {
                    case .unknown:
                        StatusCard {
                            ProgressView("Checking location permissions...")
                        }
                    case .noPermission:
                        LocationPermissionView(errorMessage: viewModel.errorMessage ?? "")
                    case .error:
                        ErrorView(message: viewModel.errorMessage ?? "Something went wrong. Please try again.")
                    case .permissionGranted:
                        if let weather = viewModel.currentWeather {
                            ScrollView {
                                WWGlassContainer(spacing: 28) {
                                    VStack(alignment: .leading, spacing: 20) {
                                        WeatherDisplay(
                                            weather: weather,
                                            meetsCriteria: weather.meets(viewModel.criteria),
                                            secondsUntilNextCheck: viewModel.secondsUntilNextCheck,
                                            coordinate: viewModel.lastCoordinate
                                        )
                                        ForecastSection(
                                            forecast: viewModel.forecast,
                                            nextGoodWindow: viewModel.nextGoodWindow,
                                            criteria: viewModel.criteria
                                        )
                                    }
                                    .padding(.vertical)
                                }
                            }
                        } else if let message = viewModel.errorMessage {
                            ErrorView(message: message)
                        } else {
                            StatusCard {
                                ProgressView("Fetching weather data...")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
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

/// Small centered glass panel used for progress and status content.
struct StatusCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(28)
            .wwGlassCard()
    }
}

struct LocationPermissionView: View {
    let errorMessage: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundStyle(.red)

            Text(errorMessage)
                .multilineTextAlignment(.center)

            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            .wwGlassButton()
        }
        .padding(28)
        .wwGlassCard(tint: WWGlassTint.danger)
    }
}

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.yellow)

            Text(message)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .wwGlassCard(tint: WWGlassTint.alert)
    }
}
