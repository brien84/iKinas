//
//  Main.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct Main: ReducerProtocol {
    struct State: Equatable {
        var dateSelector = DateSelector.State(
            dates: Calendar.current.getNextSevenDays()
        )
        var movieDetail: MovieDetail.State?
        var schedule = Schedule.State()
        var settings: Settings.State?

        var isFetchingMovies = true
        var movieClientError: MovieClient.Error?

        var isNavigationToSettingsActive: Bool {
            settings != nil
        }

        var movies: [Movie] = []
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

        case beginTransition
        case updateDatasource
        case endTransition
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.movieClient) var movieClient
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.uuid) var uuid

    private func fetchMovies(state: inout State) -> Effect<Action, Never> {
        state.isFetchingMovies = true
        state.movieClientError = nil
        let city = userDefaults.getCity()
        let venues = userDefaults.getVenues()
        return movieClient.fetch(city, venues)
            .receive(on: mainQueue)
            .catchToEffect(Action.movieClient)
    }

    private enum TransitionID { }

    private func updateDatasource() -> Effect<Action, Never> {
        Effect.run { send in
            await send(.beginTransition, animation: .easeInOut(duration: 0.3))
            try await Task.sleep(nanoseconds: 300_000_000)
            await send(.updateDatasource)
            await send(.endTransition, animation: .easeInOut(duration: 0.4))
        }
        .cancellable(id: TransitionID.self, cancelInFlight: true)
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

            case .beginTransition:
                state.schedule.isTransitioning = true
                return .none

            case .updateDatasource:
                let date = state.dateSelector.selectedDate
                state.schedule.selectedDate = date
                state.schedule.movieItems = getMovieItems(from: state.movies, on: date)
                state.schedule.showingItems = getShowingItems(from: state.movies, on: date)

                return .none

            case .endTransition:
                state.isFetchingMovies = false
                state.schedule.isTransitioning = false
                return .none

            case .dateSelector(.didSelect):
                return updateDatasource()

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
                    state.movies = movies
                    return updateDatasource()

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
        .ifLet(\.movieDetail, action: /Action.movieDetail) {
            MovieDetail()
        }
        .ifLet(\.settings, action: /Action.settings) {
            Settings()
        }
    }

    private func getMovieItems(from movies: [Movie], on date: Date) -> IdentifiedArrayOf<MovieItem.State> {
        let showings = movies.flatMap { movie in
            movie.showings.filter { $0.isShown(on: date) }
        }

        let parentMovies = Array(Set(showings.compactMap { $0.parentMovie })).sorted()
        let movieItems = parentMovies.map { MovieItem.State(id: uuid(), movie: $0) }

        return IdentifiedArray(uniqueElements: movieItems)
    }

    private func getShowingItems(from movies: [Movie], on date: Date) -> IdentifiedArrayOf<ShowingItem.State> {
        let showings = movies.flatMap { movie in
            movie.showings.filter { $0.isShown(on: date) }
        }.sorted()

        let showingItems = showings.map { ShowingItem.State(id: uuid(), showing: $0) }

        return IdentifiedArray(uniqueElements: showingItems)
    }
}
