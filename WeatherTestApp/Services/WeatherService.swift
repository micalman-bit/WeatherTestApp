// WeatherService.swift
// WeatherTestApp

import Foundation

// MARK: - Errors

enum WeatherError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case serverError(Int, String)
    case parsingError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let e):
            return "Network error: \(e.localizedDescription)"
        case .serverError(let code, _):
            return "Server returned status \(code)"
        case .parsingError(let msg):
            return "Parse error: \(msg)"
        }
    }
}

// MARK: - Protocol

protocol WeatherServiceProtocol {
    func fetchWeather(for city: City) async throws -> CityWeather
}

// MARK: - Implementation

final class WeatherService: WeatherServiceProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    nonisolated func fetchWeather(for city: City) async throws -> CityWeather {
        async let currentData  = fetchData(endpoint: "weather",  city: city)
        async let forecastData = fetchData(endpoint: "forecast", city: city)

        let (cd, fd) = try await (currentData, forecastData)

        let current: WeatherCurrentObjC
        do {
            current = try JSONParserBridge.parseCurrentWeatherData(cd)
        } catch {
            throw WeatherError.parsingError("current: \(error.localizedDescription)")
        }

        let dailyArray: [WeatherDailyObjC]
        do {
            dailyArray = try JSONParserBridge.parseForecastData(fd) as! [WeatherDailyObjC]
        } catch {
            throw WeatherError.parsingError("forecast: \(error.localizedDescription)")
        }

        return mapToModel(current: current, daily: dailyArray, city: city)
    }

    // MARK: - Private

    private func fetchData(endpoint: String, city: City) async throws -> Data {
        let urlString = "https://api.openweathermap.org/data/2.5/\(endpoint)"
            + "?lat=\(city.lat)"
            + "&lon=\(city.lon)"
            + "&appid=\(Config.apiKey)"
            + "&units=metric"

        guard let url = URL(string: urlString) else { throw WeatherError.invalidURL }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherError.networkError(error)
        }

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw WeatherError.serverError(http.statusCode, body)
        }

        return data
    }

    private func mapToModel(
        current c: WeatherCurrentObjC,
        daily dailyArr: [WeatherDailyObjC],
        city: City
    ) -> CityWeather {
        let current = CurrentWeather(
            temperature: c.temperature,
            feelsLike:   c.feelsLike,
            pressure:    Int(c.pressure),
            humidity:    Int(c.humidity),
            visibility:  Int(c.visibility),
            cloudiness:  Int(c.cloudiness),
            description: c.weatherDescription,
            iconCode:    c.iconCode
        )
        
        let daily: [DailyForecast] = dailyArr.enumerated().map { index, day in
            DailyForecast(
                id:          index,
                date:        Date(timeIntervalSince1970: day.timestamp),
                tempDay:     day.tempDay,
                tempMin:     day.tempMin,
                tempMax:     day.tempMax,
                pressure:    Int(day.pressure),
                humidity:    Int(day.humidity),
                cloudiness:  Int(day.cloudiness),
                description: day.weatherDescription,
                iconCode:    day.iconCode
            )
        }
        
        return CityWeather(city: city, current: current, daily: daily, lastUpdated: Date())
    }
}
