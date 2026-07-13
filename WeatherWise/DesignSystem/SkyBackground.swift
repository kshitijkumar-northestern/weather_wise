//
//  SkyBackground.swift
//  WeatherWise
//
//  Part of the WeatherWise Design System. A vivid, condition-aware gradient
//  with slowly drifting light blobs — deliberately rich so Liquid Glass
//  surfaces above it have something to refract.
//

import SwiftUI

struct SkyBackground: View {
    var condition: String?

    @State private var drift = false

    private var palette: [Color] {
        switch (condition ?? "").lowercased() {
        case let c where c.contains("rain") || c.contains("drizzle"):
            return [Color(red: 0.25, green: 0.32, blue: 0.45),
                    Color(red: 0.42, green: 0.50, blue: 0.62),
                    Color(red: 0.56, green: 0.62, blue: 0.70)]
        case let c where c.contains("thunder"):
            return [Color(red: 0.13, green: 0.13, blue: 0.25),
                    Color(red: 0.28, green: 0.24, blue: 0.42),
                    Color(red: 0.45, green: 0.36, blue: 0.55)]
        case let c where c.contains("snow"):
            return [Color(red: 0.62, green: 0.72, blue: 0.85),
                    Color(red: 0.78, green: 0.85, blue: 0.93),
                    Color(red: 0.90, green: 0.94, blue: 0.98)]
        case let c where c.contains("cloud"):
            return [Color(red: 0.35, green: 0.48, blue: 0.68),
                    Color(red: 0.55, green: 0.65, blue: 0.80),
                    Color(red: 0.72, green: 0.79, blue: 0.88)]
        case let c where c.contains("fog") || c.contains("mist") || c.contains("haze"):
            return [Color(red: 0.55, green: 0.58, blue: 0.62),
                    Color(red: 0.70, green: 0.72, blue: 0.75),
                    Color(red: 0.82, green: 0.83, blue: 0.85)]
        default: // clear / unknown
            return [Color(red: 0.12, green: 0.45, blue: 0.85),
                    Color(red: 0.30, green: 0.62, blue: 0.95),
                    Color(red: 0.58, green: 0.80, blue: 0.98)]
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: palette, startPoint: .top, endPoint: .bottom)

            // Drifting light blobs give glass surfaces refraction detail.
            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: drift ? -110 : 90, y: drift ? -180 : -260)

            Circle()
                .fill(palette.first?.opacity(0.55) ?? .blue.opacity(0.55))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: drift ? 130 : -100, y: drift ? 240 : 320)

            Circle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: drift ? 60 : -40, y: drift ? 40 : -30)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}
