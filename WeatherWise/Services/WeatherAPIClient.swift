//
//  WeatherAPIClient.swift
//  WeatherWise
//

import Foundation

struct WeatherAPIClient: WeatherFetching {
    let apiKey: String
    private let session: URLSession
    private let decoder: JSONDecoder

    init(apiKey: String, session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.apiKey = apiKey
        self.session = session
        self.decoder = decoder
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        let data = try await requestData(endpoint: "weather", latitude: latitude, longitude: longitude)
        do {
            let response = try decoder.decode(OpenWeatherResponse.self, from: data)
            return WeatherModel.from(response: response)
        } catch {
            throw WeatherWiseError.decodingFailed
        }
    }

    func fetchForecast(latitude: Double, longitude: Double) async throws -> [ForecastSlot] {
        let data = try await requestData(endpoint: "forecast", latitude: latitude, longitude: longitude)
        do {
            let response = try decoder.decode(ForecastResponse.self, from: data)
            return ForecastSlot.from(response: response)
        } catch {
            throw WeatherWiseError.decodingFailed
        }
    }

    private func requestData(endpoint: String, latitude: Double, longitude: Double) async throws -> Data {
        guard !apiKey.isEmpty else { throw WeatherWiseError.missingAPIKey }

        let urlString =
            "https://api.openweathermap.org/data/2.5/\(endpoint)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"
        guard let url = URL(string: urlString) else {
            throw WeatherWiseError.invalidURL
        }

        let (data, _) = try await session.data(from: url)
        return data
    }
}
