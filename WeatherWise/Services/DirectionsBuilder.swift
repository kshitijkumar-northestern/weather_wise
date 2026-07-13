//
//  DirectionsBuilder.swift
//  WeatherWise
//
//  Pure URL construction for handing a destination to Apple Maps or
//  Google Maps. Kept free of UIKit so it is trivially unit-testable;
//  actually opening the URLs happens in the view layer.
//

import Foundation

enum DirectionsBuilder {
    /// Apple Maps directions to the given coordinate.
    static func appleMaps(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: "\(latitude),\(longitude)")
        ]
        return components?.url
    }

    /// Google Maps native app deep link (requires the app to be installed;
    /// check with `canOpenURL` before opening).
    static func googleMapsApp(latitude: Double, longitude: Double) -> URL? {
        URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving")
    }

    /// Google Maps web fallback that works without the app installed.
    static func googleMapsWeb(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents(string: "https://www.google.com/maps/dir/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "destination", value: "\(latitude),\(longitude)")
        ]
        return components?.url
    }
}
