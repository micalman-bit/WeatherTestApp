// CityWeatherRow.swift
// WeatherTestApp

import SwiftUI

struct CityWeatherRow: View {
    let state: CityWeatherState
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(state.city.name)
                    .font(.headline)

                if state.isLoading {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else if let weather = state.weather {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(String(format: "%.1f°C", weather.current.temperature))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(weather.current.temperature < 10 ? Color.blue : Color.primary)

                        Text(weather.current.description.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("Updated \(formattedTime(weather.lastUpdated))")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                } else if let error = state.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .lineLimit(2)
                } else {
                    Text("Tap refresh to load")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundStyle(state.isLoading ? Color.gray : Color.accentColor)
            }
            .buttonStyle(.borderless)
            .disabled(state.isLoading)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }
}
