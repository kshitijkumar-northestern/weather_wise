//
//  SettingsView.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: .constant(true))
                }
                
                Section("Weather Preferences") {
                    Toggle("Good Weather Alerts", isOn: .constant(true))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

