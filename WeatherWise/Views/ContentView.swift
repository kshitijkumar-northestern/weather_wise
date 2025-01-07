//
//  ContentView.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var weatherService: WeatherService
    
    var body: some View {
        NavigationView {
            Group {
                switch weatherService.locationStatus {
                case .unknown:
                    ProgressView("Checking location permissions...")
                case .noPermission:
                    LocationPermissionView(errorMessage: weatherService.errorMessage ?? "")
                case .error:
                    ErrorView(message: weatherService.errorMessage ?? "Something went wrong. Please try again.")
                case .permissionGranted:
                    if let weather = weatherService.currentWeather {
                        WeatherDisplay(weather: weather, isTestMode: false) // Set to true for testing
                    } else {
                        ProgressView("Fetching weather data...")
                    }
                  
                }
            }
            .padding()
            .navigationTitle("WeatherWise")
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
