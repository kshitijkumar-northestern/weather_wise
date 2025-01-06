//
//  ContentView.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WeatherView()
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun.fill")
                }
            
            RecreationSpotsView()
                .tabItem {
                    Label("Places", systemImage: "mappin.and.ellipse")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
