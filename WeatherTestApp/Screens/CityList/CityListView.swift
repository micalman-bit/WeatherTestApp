// CityListView.swift
// WeatherTestApp

import SwiftUI

struct CityListView: View {
    @StateObject private var viewModel = CityListViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.states.indices, id: \.self) { index in
                    let state = viewModel.states[index]

                    ZStack(alignment: .leading) {
                        if let weather = state.weather {
                            NavigationLink(destination: CityDetailView(weather: weather)) {
                                EmptyView()
                            }
                            .opacity(0)
                        }

                        CityWeatherRow(state: state) {
                            viewModel.refresh(at: index)
                        }
                    }
                    .listRowBackground(rowBackground(for: state))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("World Capitals")
            .task { await viewModel.loadAll() }
        }
    }

    @ViewBuilder
    private func rowBackground(for state: CityWeatherState) -> some View {
        if let temp = state.weather?.current.temperature, temp < 10 {
            Color.blue.opacity(0.12)
        } else {
            Color(.secondarySystemGroupedBackground)
        }
    }
}
