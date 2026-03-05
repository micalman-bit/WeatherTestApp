// CityListViewModel.swift
// WeatherTestApp

import Foundation
import Combine

struct CityWeatherState: Identifiable {
    let id: Int
    let city: City
    var weather: CityWeather?
    var isLoading: Bool = false
    var error: String?

    init(city: City) {
        self.id = city.id
        self.city = city
    }
}

@MainActor
final class CityListViewModel: ObservableObject {
    @Published var states: [CityWeatherState] = City.capitals.map { CityWeatherState(city: $0) }

    private let service: WeatherServiceProtocol

    init(service: WeatherServiceProtocol = WeatherService()) {
        self.service = service
    }

    func loadAll() async {
        await withTaskGroup(of: Void.self) { group in
            for index in states.indices {
                let city = states[index].city
                group.addTask { [weak self] in
                    await self?.load(city: city, at: index)
                }
            }
        }
    }

    func refresh(at index: Int) {
        Task { await load(city: states[index].city, at: index) }
    }

    private func load(city: City, at index: Int) async {
        states[index].isLoading = true
        states[index].error = nil
        do {
            let weather = try await service.fetchWeather(for: city)
            states[index].weather = weather
        } catch {
            states[index].error = error.localizedDescription
        }
        states[index].isLoading = false
    }
}
