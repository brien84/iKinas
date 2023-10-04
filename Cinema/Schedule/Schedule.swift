//
//  Schedule.swift
//  Cinema
//
//  Created by Marius on 2022-12-18.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct Schedule: ReducerProtocol {
    struct State: Equatable {
        var filter = TimeFilter()
        var isFiltering = false
        var isTransitioning = false
        var selectedDate = Date()

        var datasource: IdentifiedArrayOf<Showing.State> = []
        var movies: IdentifiedArrayOf<Showing.State> = []
        var showings: IdentifiedArrayOf<Showing.State> = []
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case filterDatasource
        case toggleFiltering
        case movie(id: Showing.State.ID, action: Showing.Action)
        case showing(id: Showing.State.ID, action: Showing.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {

            case .binding:
                return filter(state: &state)

            case .filterDatasource:
                return filter(state: &state)

            case .toggleFiltering:
                state.isFiltering.toggle()
                return filter(state: &state)

            case .movie(id: let id, action: .networkImage(.imageClient(.success))):
                guard let networkImage = state.movies[id: id]?.networkImage else { return .none }
                state.datasource[id: id]?.networkImage = networkImage
                return .none

            case .movie:
                return .none

            case .showing(id: let id, action: .networkImage(.imageClient(.success))):
                guard let networkImage = state.showings[id: id]?.networkImage else { return .none }
                state.datasource[id: id]?.networkImage = networkImage
                return .none

            case .showing:
                return .none
            }
        }
        .forEach(\.movies, action: /Action.movie(id:action:)) {
            Showing()
        }
        .forEach(\.showings, action: /Action.showing(id:action:)) {
            Showing()
        }
    }

    private func filter(state: inout State) -> EffectTask<Action> {
        if state.isFiltering {
            guard let dates = state.filter.getFilterDates(for: state.selectedDate) else { return .none }
            state.showings = state.datasource.filter(from: dates.start, to: dates.end)
        } else {
            state.showings = state.datasource.filter(by: state.selectedDate)
        }

        state.showings = state.showings.filterFutureShowings()
        state.showings.sort(by: .date)
        let uniqueTitles = state.showings.getUniqueTitles()
        state.movies = state.datasource.filterFirstOccurrencesOf(titles: uniqueTitles)
        state.movies.sort(by: .title)
        return .none
    }
}

struct TimeFilter: Equatable {
    @BindableState var startTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @BindableState var endTime = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!

    func getFilterDates(for date: Date) -> (start: Date, end: Date)? {
        guard let startDate = Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: startTime),
            minute: Calendar.current.component(.minute, from: startTime),
            second: Calendar.current.component(.second, from: startTime),
            of: date
        ) else { return nil }

        guard let endDate = Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: endTime),
            minute: Calendar.current.component(.minute, from: endTime),
            second: Calendar.current.component(.second, from: endTime),
            of: date
        ) else { return nil }
        return (start: startDate, end: endDate)
    }
}
