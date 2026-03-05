// CityDetailView.swift
// WeatherTestApp

import SwiftUI

struct CityDetailView: View {
    let weather: CityWeather

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                currentWeatherCard
                    .padding(.horizontal)

                sectionHeader("7-Day Forecast")

                ForEach(Array(weather.daily.prefix(8).enumerated()), id: \.offset) { index, day in
                    DailyForecastRow(
                        day: day,
                        isToday: index == 0,
                        currentVisibility: index == 0 ? weather.current.visibility : nil
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(weather.city.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Current weather card

    private var currentWeatherCard: some View {
        VStack(spacing: 12) {
            Text(String(format: "%.1f°C", weather.current.temperature))
                .font(.system(size: 64, weight: .thin))

            Text(weather.current.description.capitalized)
                .font(.title3)
                .foregroundStyle(.secondary)

            Divider()

            HStack(spacing: 0) {
                statCell(
                    icon: "thermometer.medium",
                    label: "Feels like",
                    value: String(format: "%.1f°C", weather.current.feelsLike)
                )
                Divider().frame(height: 40)
                statCell(
                    icon: "drop.fill",
                    label: "Humidity",
                    value: "\(weather.current.humidity)%"
                )
                Divider().frame(height: 40)
                statCell(
                    icon: "eye",
                    label: "Visibility",
                    value: String(format: "%.1f km", Double(weather.current.visibility) / 1000)
                )
                Divider().frame(height: 40)
                statCell(
                    icon: "cloud.fill",
                    label: "Clouds",
                    value: "\(weather.current.cloudiness)%"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statCell(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

// MARK: - Daily forecast row

private let rowDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "EEEE, MMM d"
    return f
}()

struct DailyForecastRow: View {
    let day: DailyForecast
    let isToday: Bool
    let currentVisibility: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(isToday ? "Today" : rowDateFormatter.string(from: day.date))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(day.description.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 0) {
                forecastCell(
                    icon: "thermometer.medium",
                    label: "Temp",
                    value: String(format: "%.0f° / %.0f°", day.tempMax, day.tempMin)
                )
                Divider().frame(height: 36)
                forecastCell(
                    icon: "gauge",
                    label: "Pressure",
                    value: "\(day.pressure) hPa"
                )
                Divider().frame(height: 36)
                forecastCell(
                    icon: "drop.fill",
                    label: "Humidity",
                    value: "\(day.humidity)%"
                )
                Divider().frame(height: 36)
                forecastCell(
                    icon: "eye",
                    label: "Visibility",
                    value: currentVisibility.map { String(format: "%.1f km", Double($0) / 1000) } ?? "—"
                )
                Divider().frame(height: 36)
                forecastCell(
                    icon: "cloud.fill",
                    label: "Clouds",
                    value: "\(day.cloudiness)%"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func forecastCell(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
