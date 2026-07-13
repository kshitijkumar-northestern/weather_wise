//
//  WeatherCriteria.swift
//  WeatherWise
//

import Foundation

/// User-configurable thresholds that decide whether outdoor weather is "ideal".
struct WeatherCriteria: Codable, Equatable {
    var minimumTemperature: Double
    var maximumTemperature: Double
    var maximumHumidity: Int
    var maximumWindSpeed: Double
    /// Seconds between foreground weather checks.
    var checkInterval: TimeInterval

    static let `default` = WeatherCriteria(
        minimumTemperature: 65,
        maximumTemperature: 77,
        maximumHumidity: 70,
        maximumWindSpeed: 12,
        checkInterval: 1800
    )

    /// Keeps values in a sane order and range for sliders / steppers.
    mutating func normalize() {
        if minimumTemperature > maximumTemperature {
            swap(&minimumTemperature, &maximumTemperature)
        }
        minimumTemperature = min(max(minimumTemperature, -20), 120)
        maximumTemperature = min(max(maximumTemperature, -20), 120)
        maximumHumidity = min(max(maximumHumidity, 1), 100)
        maximumWindSpeed = min(max(maximumWindSpeed, 1), 80)
        checkInterval = min(max(checkInterval, 60), 7200)
    }
}
