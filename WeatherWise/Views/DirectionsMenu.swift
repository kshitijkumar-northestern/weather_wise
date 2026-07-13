//
//  DirectionsMenu.swift
//  WeatherWise
//
//  Glass menu offering directions to a coordinate in Apple Maps or
//  Google Maps (native app when installed, web fallback otherwise).
//

import SwiftUI

struct DirectionsMenu: View {
    let latitude: Double
    let longitude: Double
    /// Compact renders an icon-only glass circle (for list rows);
    /// full renders a labeled glass capsule.
    var compact: Bool = false

    var body: some View {
        Menu {
            Button {
                openAppleMaps()
            } label: {
                Label("Apple Maps", systemImage: "map.fill")
            }
            Button {
                openGoogleMaps()
            } label: {
                Label("Google Maps", systemImage: "globe.americas.fill")
            }
        } label: {
            if compact {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.subheadline)
                    .padding(10)
                    .wwGlassCircle(tint: WWGlassTint.hero)
            } else {
                Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.subheadline.weight(.medium))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .wwGlassCapsule(tint: WWGlassTint.hero)
            }
        }
        .accessibilityLabel("Get directions")
    }

    private func openAppleMaps() {
        guard let url = DirectionsBuilder.appleMaps(latitude: latitude, longitude: longitude) else { return }
        UIApplication.shared.open(url)
    }

    private func openGoogleMaps() {
        if let appURL = DirectionsBuilder.googleMapsApp(latitude: latitude, longitude: longitude),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = DirectionsBuilder.googleMapsWeb(latitude: latitude, longitude: longitude) {
            UIApplication.shared.open(webURL)
        }
    }
}
