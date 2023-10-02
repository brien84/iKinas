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
        var dateSelector = DateSelector.State(dates: [])
        var homeFeed = HomeFeed.State()
        var movieInfo: MovieInfo.State?
        var schedule = Schedule.State()
        var settings: Settings.State?

        var isHomeFeedActive = true
        var isHomeFeedButtonSelected = true

        var isFetching = true
        var apiError: APIClient.Error?

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

        case fetch
        case apiClient(Result<APIClient.Response, Never>)

        case setNavigationToMovieInfo(isActive: Bool)
        case setNavigationToSettings(isActive: Bool)

        case didPressHomeFeedButton
        case beginTransition
        case updateDatasource
        case endTransition
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.mainQueue) var mainQueue
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

            case .homeFeed(.scheduleButtonDidTap):
                guard let date = state.dateSelector.dates.first else { return .none }
                state.isHomeFeedButtonSelected = false
                state.dateSelector.selectedDate = date
                return performTransition()

            case .homeFeed(.settingsButtonDidTap):
                state.settings = Settings.State()
                return .none

            case .homeFeed:
                return .none

            case .movieInfo:
                return .none

            case .schedule(.movie(id: let id, action: .didSelect)):
                if let showing = state.schedule.datasource[id: id] {
                    state.movieInfo = MovieInfo.State(showing: showing, shouldDisplayTicketURL: false)
                }
                return .none

            case .schedule(.showing(id: let id, action: .didSelect)):
                if let showing = state.schedule.datasource[id: id] {
                    state.movieInfo = MovieInfo.State(showing: showing, shouldDisplayTicketURL: true)
                }
                return .none

            case .schedule:
                return .none

            case .settings(.saveSettings):
                return fetch(state: &state)

            case .settings:
                return .none

            case .fetch:
                return fetch(state: &state)

            case .apiClient(.success(let response)):
                switch response {
                case .success:
                    let showings = apiClient.getShowings()
                    state.dateSelector = DateSelector.State(dates: showings.getUpcomingDays())
                    state.schedule.datasource = showings
                    return performTransition()

                case .failure(let error):
                    switch error {
                    case .network, .decoding:
                        state.apiError = .network
                    case .requiresUpdate:
                        state.apiError = .requiresUpdate
                    }
                    return . none
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
                state.dateSelector.selectedDate = .none
                return performTransition()

            case .beginTransition:
                state.homeFeed.isTransitioning = true
                state.schedule.isTransitioning = true
                return .none

            case .updateDatasource:
                state.isHomeFeedActive = state.isHomeFeedButtonSelected
                state.schedule.selectedDate = state.dateSelector.selectedDate
                return EffectTask.task { .schedule(.filterDatasource) }

            case .endTransition:
                state.isFetching = false
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

    private func fetch(state: inout State) -> EffectTask<Action> {
        state.isFetching = true
        state.apiError = nil
        let city = userDefaults.getCity()
        let venues = userDefaults.getVenues()
        return apiClient.fetch(city, venues)
            .delay(for: .milliseconds(750), scheduler: mainQueue)
            .receive(on: mainQueue)
            .catchToEffect(Action.apiClient)
    }

    private enum CancelID { case transition }

    private func performTransition() -> EffectTask<Action> {
        EffectTask.run { send in
            try await Task.sleep(nanoseconds: 50_000_000)
            await send(.beginTransition, animation: .easeInOut(duration: 0.3))
            try await Task.sleep(nanoseconds: 300_000_000)
            await send(.updateDatasource)
            try await Task.sleep(nanoseconds: 100_000_000)
            await send(.endTransition, animation: .easeInOut(duration: 0.4))
        }
        .cancellable(id: CancelID.transition, cancelInFlight: true)
    }
}
