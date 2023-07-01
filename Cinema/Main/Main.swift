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
            dates: Calendar.current.getNextSevenDays(),
            selectedDate: .distantPast
        )
        var homeFeed = HomeFeed.State()
        var movieInfo: MovieInfo.State?
        var schedule = Schedule.State()
        var settings: Settings.State?

        var isHomeFeedActive = true
        var isHomeFeedButtonSelected = true

        var isFetchingMovies = true
        var movieClientError: MovieClient.Error?

        var isNavigationToSettingsActive: Bool {
            settings != nil
        }
    }

    enum Action: Equatable {
        case dateSelector(DateSelector.Action)
        case homeFeed(HomeFeed.Action)
        case movieInfo(MovieInfo.Action)
        case schedule(Schedule.Action)
        case settings(Settings.Action)

        case fetchMovies
        case movieClient(Result<[Movie], MovieClient.Error>)

        case setNavigationToMovieInfo(isActive: Bool)
        case setNavigationToSettings(isActive: Bool)

        case didPressHomeFeedButton
        case beginTransition
        case updateDatasource
        case endTransition
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.movieClient) var movieClient
    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.dateSelector, action: /Action.dateSelector) {
            DateSelector()
        }

        Scope(state: \.homeFeed, action: /Action.homeFeed) {
            HomeFeed()
        }

        Scope(state: \.schedule, action: /Action.schedule) {
            Schedule()
        }

        Reduce { state, action in
            switch action {

            case .dateSelector(.didSelect):
                state.isHomeFeedButtonSelected = false
                return performTransition()

            case .homeFeed(.settingsButtonDidTap):
                state.settings = Settings.State()
                return .none

            case .homeFeed:
                return .none

            case .movieInfo:
                return .none

            case .schedule(.movieItem(id: let id, action: .didSelect)):
                if let item = state.schedule.items[id: id] {
                    state.movieInfo = MovieInfo.State(movie: item.movie, showing: nil)
                }
                return .none

            case .schedule(.showingItem(id: let id, action: .didSelect)):
                if let item = state.schedule.items[id: id] {
                    state.movieInfo = MovieInfo.State(movie: item.movie, showing: item.showing)
                }
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
                    let items = movies.flatMap {
                        $0.showings.compactMap { ScheduleItem.State(showing: $0) }
                    }
                    state.schedule.items = IdentifiedArray(uniqueElements: items)
                    return performTransition()

                case .failure(let error):
                    switch error {
                    case .network, .decoding:
                        state.movieClientError = .network
                    case .requiresUpdate:
                        state.movieClientError = .requiresUpdate
                    }
                    return .none
                }

            case .setNavigationToMovieInfo(let isActive):
                if !isActive {
                    state.movieInfo = nil
                }
                return .none

            case .setNavigationToSettings(let isActive):
                if !isActive {
                    state.settings = nil
                } else {
                    state.settings = Settings.State()
                }
                return .none

            case .didPressHomeFeedButton:
                state.isHomeFeedButtonSelected = true
                state.dateSelector.selectedDate = .distantPast
                return performTransition()

            case .beginTransition:
                state.homeFeed.isTransitioning = true
                state.schedule.isTransitioning = true
                return .none

            case .updateDatasource:
                state.isHomeFeedActive = state.isHomeFeedButtonSelected
                state.schedule.selectedDate = state.dateSelector.selectedDate
                return Effect(value: .schedule(.filterItems))

            case .endTransition:
                state.isFetchingMovies = false
                state.homeFeed.isTransitioning  = false
                state.schedule.isTransitioning = false
                return .none

            }
        }
        .ifLet(\.movieInfo, action: /Action.movieInfo) {
            MovieInfo()
        }
        .ifLet(\.settings, action: /Action.settings) {
            Settings()
        }
    }

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

    private func performTransition() -> Effect<Action, Never> {
        Effect.run { send in
            await send(.beginTransition, animation: .easeInOut(duration: 0.3))
            try await Task.sleep(nanoseconds: 300_000_000)
            await send(.updateDatasource)
            try await Task.sleep(nanoseconds: 100_000_000)
            await send(.endTransition, animation: .easeInOut(duration: 0.4))
        }
        .cancellable(id: TransitionID.self, cancelInFlight: true)
    }
}
