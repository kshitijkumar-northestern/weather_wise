//
//  WeatherView.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Text("Current Weather")
                .font(.largeTitle)
                .padding()
            
            Group {
                switch locationManager.authorizationStatus {
                case .notDetermined:
                    Text("Please allow location access")
                        .padding()
                case .restricted, .denied:
                    VStack {
                        Text("Location access is denied")
                            .foregroundColor(.red)
                        Text("Please enable location access in Settings to see weather information")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Open Settings") {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
                        }
                    }
                case .authorizedWhenInUse, .authorizedAlways:
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text("\(Int(viewModel.temperature))°C")
                            .font(.system(size: 70))
                            .bold()
                        
                        Text(viewModel.condition)
                            .font(.title2)
                            .padding()
                        
                        if viewModel.isGoodWeather {
                            Text("Great weather for outdoor activities!")
                                .foregroundColor(.green)
                                .padding()
                        }
                    }
                @unknown default:
                    Text("Unknown authorization status")
                }
            }
            .padding()
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if let location = newLocation {
                viewModel.updateWeather(for: location)
            }
        }
    }
}




