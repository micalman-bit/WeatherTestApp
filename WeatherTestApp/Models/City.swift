// City.swift
// WeatherTestApp

import Foundation

struct City: Identifiable, Hashable {
    let id: Int
    let name: String
    let lat: Double
    let lon: Double
}

extension City {
    static let capitals: [City] = [
        City(id: 0, name: "London",   lat: 51.5074,  lon: -0.1278),
        City(id: 1, name: "Paris",    lat: 48.8566,  lon:  2.3522),
        City(id: 2, name: "New York", lat: 40.7128,  lon: -74.0060),
        City(id: 3, name: "Rome",     lat: 41.9028,  lon:  12.4964),
        City(id: 4, name: "Moscow",   lat: 55.7558,  lon:  37.6173)
    ]
}
