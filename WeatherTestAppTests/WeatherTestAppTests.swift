// WeatherTestAppTests.swift
// WeatherTestApp

import XCTest
@testable import WeatherTestApp

final class WeatherTestAppTests: XCTestCase {

    // MARK: - City model tests

    func testCapitalsCount() {
        XCTAssertEqual(City.capitals.count, 5)
    }

    func testCapitalNames() {
        let names = City.capitals.map(\.name)
        XCTAssertTrue(names.contains("London"))
        XCTAssertTrue(names.contains("Paris"))
        XCTAssertTrue(names.contains("New York"))
        XCTAssertTrue(names.contains("Rome"))
        XCTAssertTrue(names.contains("Moscow"))
    }

    func testCapitalCoordinatesAreValid() {
        for city in City.capitals {
            XCTAssertTrue((-90...90).contains(city.lat),   "\(city.name): lat out of range")
            XCTAssertTrue((-180...180).contains(city.lon), "\(city.name): lon out of range")
        }
    }

    func testCapitalIdsAreUnique() {
        let ids = City.capitals.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    // MARK: - Temperature cold-threshold tests

    func testColdTemperatureThreshold() {
        XCTAssertTrue(isCold(9.9))
        XCTAssertTrue(isCold(-5))
        XCTAssertFalse(isCold(10.0))
        XCTAssertFalse(isCold(25))
    }

    private func isCold(_ temp: Double) -> Bool { temp < 10 }

    // MARK: - Current weather JSON parsing

    func testParseCurrentWeather() throws {
        let data = try XCTUnwrap(currentWeatherJSON().data(using: .utf8))
        let result = try JSONParserBridge.parseCurrentWeatherData(data)

        XCTAssertEqual(result.temperature,  12.5, accuracy: 0.001)
        XCTAssertEqual(result.feelsLike,    10.3, accuracy: 0.001)
        XCTAssertEqual(result.pressure,     1015)
        XCTAssertEqual(result.humidity,     72)
        XCTAssertEqual(result.visibility,   9000)
        XCTAssertEqual(result.cloudiness,   40)
        XCTAssertEqual(result.weatherDescription, "light rain")
        XCTAssertEqual(result.iconCode, "10d")
    }

    func testParseCurrentWeatherIntegerTemp() throws {
        let data = try XCTUnwrap(currentWeatherJSONIntegerTemp().data(using: .utf8))
        let result = try JSONParserBridge.parseCurrentWeatherData(data)
        XCTAssertEqual(result.temperature, 10.0, accuracy: 0.001)
    }

    func testParseCurrentWeatherInvalidJSON() {
        let data = "{ bad json }".data(using: .utf8)!
        XCTAssertThrowsError(try JSONParserBridge.parseCurrentWeatherData(data))
    }

    // MARK: - Forecast JSON parsing

    func testParseForecast() throws {
        let data = try XCTUnwrap(forecastJSON().data(using: .utf8))
        let result = try JSONParserBridge.parseForecastData(data) as! [WeatherDailyObjC]

        XCTAssertGreaterThanOrEqual(result.count, 1)

        let first = result[0]
        XCTAssertEqual(first.tempMin, 8.0,  accuracy: 0.001)
        XCTAssertEqual(first.tempMax, 14.0, accuracy: 0.001)
        XCTAssertEqual(first.pressure,   1013)
        XCTAssertEqual(first.humidity,   68)
        XCTAssertEqual(first.cloudiness, 55)
    }

    func testParseForecastInvalidJSON() {
        let data = "not json".data(using: .utf8)!
        XCTAssertThrowsError(try JSONParserBridge.parseForecastData(data))
    }

    // MARK: - JSON fixtures

    private func currentWeatherJSON() -> String {
        """
        {
          "main": { "temp": 12.5, "feels_like": 10.3, "pressure": 1015, "humidity": 72 },
          "visibility": 9000,
          "clouds": { "all": 40 },
          "weather": [{ "description": "light rain", "icon": "10d" }]
        }
        """
    }

    private func currentWeatherJSONIntegerTemp() -> String {
        """
        {
          "main": { "temp": 10, "feels_like": 8, "pressure": 1020, "humidity": 80 },
          "visibility": 8000,
          "clouds": { "all": 30 },
          "weather": [{ "description": "clear sky", "icon": "01d" }]
        }
        """
    }

    private func forecastJSON() -> String {
        """
        {
          "list": [
            {
              "dt": 1700000000,
              "main": { "temp": 11.0, "temp_min": 8.0, "temp_max": 14.0, "pressure": 1013, "humidity": 68 },
              "clouds": { "all": 55 },
              "weather": [{ "description": "light rain", "icon": "10d" }]
            }
          ]
        }
        """
    }
}
