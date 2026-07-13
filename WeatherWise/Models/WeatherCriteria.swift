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
    /// When enabled, notifications are suppressed between the quiet hours.
    var quietHoursEnabled: Bool
    /// Hour of day (0–23) when quiet hours begin.
    var quietStartHour: Int
    /// Hour of day (0–23) when quiet hours end.
    var quietEndHour: Int

    static let `default` = WeatherCriteria(
        minimumTemperature: 65,
        maximumTemperature: 77,
        maximumHumidity: 70,
        maximumWindSpeed: 12,
        checkInterval: 1800,
        quietHoursEnabled: false,
        quietStartHour: 22,
        quietEndHour: 7
    )

    init(
        minimumTemperature: Double,
        maximumTemperature: Double,
        maximumHumidity: Int,
        maximumWindSpeed: Double,
        checkInterval: TimeInterval,
        quietHoursEnabled: Bool = false,
        quietStartHour: Int = 22,
        quietEndHour: Int = 7
    ) {
        self.minimumTemperature = minimumTemperature
        self.maximumTemperature = maximumTemperature
        self.maximumHumidity = maximumHumidity
        self.maximumWindSpeed = maximumWindSpeed
        self.checkInterval = checkInterval
        self.quietHoursEnabled = quietHoursEnabled
        self.quietStartHour = quietStartHour
        self.quietEndHour = quietEndHour
    }

    // Custom decoding keeps criteria saved by older app versions loadable:
    // the quiet-hours keys fall back to defaults when absent.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        minimumTemperature = try container.decode(Double.self, forKey: .minimumTemperature)
        maximumTemperature = try container.decode(Double.self, forKey: .maximumTemperature)
        maximumHumidity = try container.decode(Int.self, forKey: .maximumHumidity)
        maximumWindSpeed = try container.decode(Double.self, forKey: .maximumWindSpeed)
        checkInterval = try container.decode(TimeInterval.self, forKey: .checkInterval)
        quietHoursEnabled = try container.decodeIfPresent(Bool.self, forKey: .quietHoursEnabled) ?? false
        quietStartHour = try container.decodeIfPresent(Int.self, forKey: .quietStartHour) ?? 22
        quietEndHour = try container.decodeIfPresent(Int.self, forKey: .quietEndHour) ?? 7
    }

    /// Core evaluation shared by current conditions and forecast slots.
    func isSatisfied(temperature: Double, humidity: Int, windSpeed: Double) -> Bool {
        temperature >= minimumTemperature &&
        temperature <= maximumTemperature &&
        humidity < maximumHumidity &&
        windSpeed < maximumWindSpeed
    }

    /// True when `date` falls inside the configured quiet hours.
    /// Handles ranges that wrap midnight (e.g. 22:00–07:00).
    func isQuietTime(_ date: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard quietHoursEnabled else { return false }
        let hour = calendar.component(.hour, from: date)
        if quietStartHour == quietEndHour {
            return true
        }
        if quietStartHour < quietEndHour {
            return hour >= quietStartHour && hour < quietEndHour
        }
        return hour >= quietStartHour || hour < quietEndHour
    }

    /// Keeps values in a sane order and range for steppers / pickers.
    mutating func normalize() {
        if minimumTemperature > maximumTemperature {
            swap(&minimumTemperature, &maximumTemperature)
        }
        minimumTemperature = min(max(minimumTemperature, -20), 120)
        maximumTemperature = min(max(maximumTemperature, -20), 120)
        maximumHumidity = min(max(maximumHumidity, 1), 100)
        maximumWindSpeed = min(max(maximumWindSpeed, 1), 80)
        checkInterval = min(max(checkInterval, 60), 7200)
        quietStartHour = min(max(quietStartHour, 0), 23)
        quietEndHour = min(max(quietEndHour, 0), 23)
    }
}
