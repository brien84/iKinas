//
//  Main.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture

struct Main: ReducerProtocol {

    struct State: Equatable {
        var dateSelector = DateSelector.State()
        var schedule = Schedule.State()
        var settings: Settings.State?

        var requiresToFetchMovies = true

        var isNavigationToSettingsActive: Bool {
            settings != nil
        }

        var selectedMovie: Movie?
        var selectedShowing: Showing?

        var movieClientError: MovieClient.Error?
    }

    enum Action: Equatable {
        case deselect
        case fetchMovies

        case dateSelector(action: DateSelector.Action)
        case schedule(action: Schedule.Action)
        case settings(action: Settings.Action)
        case setNavigationToSettings(isActive: Bool)

        case movieClient(Result<[Movie], MovieClient.Error>)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.movieClient) var movieClient

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.dateSelector, action: /Action.dateSelector) {
            DateSelector()
        }

        Scope(state: \.schedule, action: /Action.schedule) {
            Schedule()
        }

        Reduce { state, action in
            switch action {

            case .deselect:
                state.selectedMovie = nil
                state.selectedShowing = nil
                return .none

            case .fetchMovies:
                state.requiresToFetchMovies = true
                state.movieClientError = nil
                return movieClient.fetch()
                    .receive(on: mainQueue)
                    .catchToEffect(Action.movieClient)

            case .dateSelector(.didSelect(date: let date)):
                let datasource = Schedule.Datasource(
                    date: date,
                    movies: state.schedule.movies
                )
                return Effect(value: .schedule(action: .datasourceNeedsUpdate(datasource)))

            case .dateSelector:
                return .none

            case .schedule(action: .movieList(action: .movieItem(id: _, action: .didSelectMovie(let movie)))):
                state.selectedMovie = movie
                return .none

            case .schedule(action: .showingList(action: .showingItem(id: _, action: .didSelectShowing(let showing)))):
                state.selectedShowing = showing
                return .none

            case .schedule(action: .endTransition):
                if state.requiresToFetchMovies {
                    state.requiresToFetchMovies = false
                }

                return .none

            case .schedule(action: .settingsButtonDidTap):
                state.settings = Settings.State()
                return .none

            case .schedule:
                return .none

            case .settings(action: .saveSettings):
                state.requiresToFetchMovies = true
                return .none

            case .settings:
                return .none

            case .setNavigationToSettings(let isActive):
                state.settings = isActive ? Settings.State() : nil
                return .none

            case .movieClient(let result):
                switch result {
                case .success(let movies):
                    let datasource = Schedule.Datasource(
                        date: state.dateSelector.selectedDate,
                        movies: movies
                    )
                    return Effect(value: .schedule(action: .datasourceNeedsUpdate(datasource)))
                case .failure(let error):
                    switch error {
                    case .requiresUpdate:
                        state.movieClientError = .requiresUpdate
                    case .network, .decoding:
                        state.movieClientError = .network
                    }
                    return .none
                }

            }
        }
        .ifLet(\.settings, action: /Action.settings) {
            Settings()
        }

    }
}
