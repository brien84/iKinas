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
        var movieDetail: MovieDetail.State?
        var schedule = Schedule.State()
        var settings: Settings.State?

        var requiresToFetchMovies = true

        var isNavigationToSettingsActive: Bool {
            settings != nil
        }

        var movieClientError: MovieClient.Error?
    }

    enum Action: Equatable {
        case fetchMovies

        case dateSelector(DateSelector.Action)
        case schedule(Schedule.Action)
        case settings(Settings.Action)
        case setNavigationToMovieDetail(isActive: Bool)
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

            case .dateSelector(.didSelect(date: let date)):
                state.schedule.datasource.date = date
                state.dateSelector.isDisabled = true
                return .none

            case .dateSelector:
                return .none

            case .fetchMovies:
                state.requiresToFetchMovies = true
                state.movieClientError = nil
                return movieClient.fetch()
                    .receive(on: mainQueue)
                    .catchToEffect(Action.movieClient)

            case .movieClient(let result):
                switch result {
                case .success(let movies):
                    state.schedule.datasource.movies = movies
                    state.dateSelector.isDisabled = true
                    return .none

                case .failure(let error):
                    switch error {
                    case .requiresUpdate:
                        state.movieClientError = .requiresUpdate
                    case .network, .decoding:
                        state.movieClientError = .network
                    }
                    return .none
                }

            case .schedule(.movieItem(id: _, action: .didSelectMovie(let movie))):
                state.movieDetail = MovieDetail.State(movie: movie, showing: nil)
                return .none

            case .schedule(.showingItem(id: _, action: .didSelectShowing(let showing))):
                guard let movie = showing.parentMovie else { return .none }
                state.movieDetail = MovieDetail.State(movie: movie, showing: showing)
                return .none

            case .schedule(.settingsButtonDidTap):
                state.settings = Settings.State()
                return .none

            case .schedule(.transitionDidEnd):
                state.dateSelector.isDisabled = false
                state.requiresToFetchMovies = false
                return .none

            case .schedule:
                return .none

            case .setNavigationToMovieDetail(let isActive):
                if !isActive {
                    state.movieDetail = nil
                }
                return .none

            case .setNavigationToSettings(let isActive):
                state.settings = isActive ? Settings.State() : nil
                return .none

            case .settings(.saveSettings):
                state.requiresToFetchMovies = true
                return .none

            case .settings:
                return .none

            }
        }
        .ifLet(\.settings, action: /Action.settings) {
            Settings()
        }

    }
}
