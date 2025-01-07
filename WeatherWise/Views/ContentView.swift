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
                        WeatherDisplay(weather: weather)
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

