//
//  WeatherWiseApp.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import SwiftUI

@main
struct WeatherWiseApp: App {
    @StateObject private var weatherService = WeatherService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(weatherService)
                .onAppear {
                    weatherService.startPeriodicWeatherChecks()
                }
        }
    }
}


