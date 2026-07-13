//
//  WeatherCheckRecord.swift
//  WeatherWise
//

import Foundation

/// One persisted evaluation of weather against the user's criteria.
struct WeatherCheckRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let condition: String
    let locationName: String
    let metCriteria: Bool
    // Optional so records saved by earlier app versions still decode.
    let latitude: Double?
    let longitude: Double?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        temperature: Double,
        humidity: Int,
        windSpeed: Double,
        condition: String,
        locationName: String,
        metCriteria: Bool,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.temperature = temperature
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.condition = condition
        self.locationName = locationName
        self.metCriteria = metCriteria
        self.latitude = latitude
        self.longitude = longitude
    }

    init(
        weather: WeatherModel,
        metCriteria: Bool,
        timestamp: Date = Date(),
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.init(
            timestamp: timestamp,
            temperature: weather.temperature,
            humidity: weather.humidity,
            windSpeed: weather.windSpeed,
            condition: weather.condition,
            locationName: weather.locationName,
            metCriteria: metCriteria,
            latitude: latitude,
            longitude: longitude
        )
    }
}
