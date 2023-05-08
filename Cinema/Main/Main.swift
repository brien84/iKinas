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

        var movieClientError: MovieClient.Error?
        var isFetchingMovies = true

        var isNavigationToSettingsActive: Bool {
            settings != nil
        }
    }

    enum Action: Equatable {
        case dateSelector(DateSelector.Action)
        case movieDetail(MovieDetail.Action)
        case schedule(Schedule.Action)
        case settings(Settings.Action)

        case fetchMovies
        case movieClient(Result<[Movie], MovieClient.Error>)

        case setNavigationToMovieDetail(isActive: Bool)
        case setNavigationToSettings(isActive: Bool)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.movieClient) var movieClient
    @Dependency(\.userDefaults) var userDefaults

    private func fetchMovies(state: inout State) -> Effect<Action, Never> {
        state.isFetchingMovies = true
        state.movieClientError = nil
        let city = userDefaults.getCity()
        let venues = userDefaults.getVenues()
        return movieClient.fetch(city, venues)
            .receive(on: mainQueue)
            .catchToEffect(Action.movieClient)
    }

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
                return .none

            case .dateSelector:
                return .none

            case .movieDetail:
                return .none

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
                state.isFetchingMovies = false
                return .none

            case .schedule:
                return .none

            case .settings(.saveSettings):
                return fetchMovies(state: &state)

            case .settings:
                return .none

            case .fetchMovies:
                return fetchMovies(state: &state)

            case .movieClient(let result):
                switch result {
                case .success(let movies):
                    state.schedule.datasource.movies = movies
                    return .none
                case .failure(let error):
                    switch error {
                    case .network, .decoding:
                        state.movieClientError = .network
                    case .requiresUpdate:
                        state.movieClientError = .requiresUpdate
                    }
                    return .none
                }

            case .setNavigationToMovieDetail(let isActive):
                if !isActive {
                    state.movieDetail = nil
                }
                return .none

            case .setNavigationToSettings(let isActive):
                if !isActive {
                    state.settings = nil
                } else {
                    state.settings = Settings.State()
                }
                return .none

            }
        }
        .ifLet(\.settings, action: /Action.settings) {
            Settings()
        }
        .ifLet(\.movieDetail, action: /Action.movieDetail) {
            MovieDetail()
        }
    }
}
