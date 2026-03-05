// CityDetailViewModel.swift
// WeatherTestApp

import Foundation
import Combine

@MainActor
final class CityDetailViewModel: ObservableObject {
    @Published private(set) var weather: CityWeather

    var city: City { weather.city }
    var current: CurrentWeather { weather.current }
    var daily: [DailyForecast] { weather.daily }

    init(weather: CityWeather) {
        self.weather = weather
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "E, MMM d"
        return f
    }()

    func formattedDate(_ date: Date, isToday: Bool) -> String {
        isToday ? "Today" : Self.dateFormatter.string(from: date)
    }
}
