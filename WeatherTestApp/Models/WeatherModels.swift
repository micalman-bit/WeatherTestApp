// WeatherModels.swift
// WeatherTestApp

import Foundation

struct CurrentWeather {
    let temperature: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let visibility: Int
    let cloudiness: Int
    let description: String
    let iconCode: String
}

struct DailyForecast: Identifiable {
    let id: Int
    let date: Date
    let tempDay: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let cloudiness: Int
    let description: String
    let iconCode: String
}

struct CityWeather {
    let city: City
    let current: CurrentWeather
    let daily: [DailyForecast]
    let lastUpdated: Date
}
