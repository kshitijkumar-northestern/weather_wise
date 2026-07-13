//
//  Forecast.swift
//  WeatherWise
//

import Foundation

/// DTO for the OpenWeatherMap "5 day / 3 hour" forecast endpoint.
struct ForecastResponse: Codable {
    let list: [Item]

    struct Item: Codable {
        let dt: TimeInterval
        let main: Main
        let wind: Wind
        let weather: [Weather]
    }
}

/// One 3-hour forecast slot in the domain model.
struct ForecastSlot: Identifiable, Equatable {
    let date: Date
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let condition: String

    var id: Date { date }

    /// Duration each forecast slot covers (OpenWeatherMap returns 3-hour steps).
    static let slotDuration: TimeInterval = 3 * 3600

    func meets(_ criteria: WeatherCriteria) -> Bool {
        criteria.isSatisfied(temperature: temperature, humidity: humidity, windSpeed: windSpeed)
    }

    static func from(response: ForecastResponse) -> [ForecastSlot] {
        response.list.map { item in
            ForecastSlot(
                date: Date(timeIntervalSince1970: item.dt),
                temperature: item.main.temp,
                humidity: item.main.humidity,
                windSpeed: item.wind.speed,
                condition: item.weather.first?.main ?? "Unknown"
            )
        }
        .sorted { $0.date < $1.date }
    }
}

/// The next contiguous stretch of forecast slots matching the user's criteria.
struct GoodWeatherWindow: Equatable {
    let start: Date
    let end: Date

    static func next(
        in slots: [ForecastSlot],
        criteria: WeatherCriteria,
        after referenceDate: Date = Date()
    ) -> GoodWeatherWindow? {
        let upcoming = slots
            .filter { $0.date.addingTimeInterval(ForecastSlot.slotDuration) > referenceDate }
            .sorted { $0.date < $1.date }

        var start: Date?
        var end: Date?

        for slot in upcoming {
            if slot.meets(criteria) {
                if start == nil {
                    start = slot.date
                }
                end = slot.date.addingTimeInterval(ForecastSlot.slotDuration)
            } else if start != nil {
                break
            }
        }

        guard let start, let end else { return nil }
        return GoodWeatherWindow(start: max(start, referenceDate), end: end)
    }
}
