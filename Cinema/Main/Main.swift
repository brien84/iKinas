//
//  Main.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation
import StoreKit

struct Main: ReducerProtocol {
    struct State: Equatable {
        var dateSelector = DateSelector.State(dates: [])
        var homeFeed = HomeFeed.State()
        var schedule = Schedule.State()
        var settings: Settings.State?
        var showingInfo: ShowingInfo.State?

        var isHomeFeedActive = true
        var isHomeFeedButtonSelected = true

        var apiError: APIClient.Error?
        var isFetching = true
        var shouldAskForReview = false

        var isNavigationToSettingsActive: Bool {
            settings != nil
        }
    }

    enum Action: Equatable {
        case dateSelector(DateSelector.Action)
        case homeFeed(HomeFeed.Action)
        case schedule(Schedule.Action)
        case settings(Settings.Action)

        case fetch
        case apiClient(Result<APIClient.Response, Never>)

        case setNavigationToSettings(isActive: Bool)
        case setNavigationToShowingInfo(isActive: Bool)

        case homefeedButtonDidTap
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
                state.shouldAskForReview = userDefaults.shouldAskForReview()
                return performTransition()

            case .homeFeed(.scheduleButtonDidTap):
                let dates = apiClient.getShowings().getUpcomingDays()
                guard let date = dates.first else { return .none }
                state.isHomeFeedButtonSelected = false
                state.schedule.isTimeFiltering = false
                state.dateSelector.selectedDate = date
                state.shouldAskForReview = userDefaults.shouldAskForReview()
                return performTransition()

            case .homeFeed(.settingsButtonDidTap):
                state.settings = Settings.State()
                return .none

            case .homeFeed(.featured(id: let id, action: .didSelect)):
                guard let featured = state.homeFeed.featured[id: id] else { return .none }
                guard let showing = state.schedule.datasource.first(where: { $0.title == featured.title }) else { return .none }
                state.showingInfo = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: false)
                return .none

            case .homeFeed(.upcoming(id: let id, action: .didSelect)):
                if let showing = state.homeFeed.upcoming[id: id] {
                    state.showingInfo = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: true)
                }
                return .none

            case .homeFeed:
                return .none

            case .schedule(.movie(id: let id, action: .didSelect)):
                if let showing = state.schedule.datasource[id: id] {
                    state.showingInfo = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: false)
                }
                return .none

            case .schedule(.showing(id: let id, action: .didSelect)):
                if let showing = state.schedule.datasource[id: id] {
                    state.showingInfo = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: true)
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
                    state.homeFeed.featured = apiClient.getFeatured()
                    let showings = apiClient.getShowings()
                    state.dateSelector = DateSelector.State(dates: showings.getUpcomingDays())
                    state.schedule.datasource = showings
                    state.schedule.isTimeFiltering = false
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

            case .setNavigationToShowingInfo(let isActive):
                if !isActive {
                    state.showingInfo = nil
                }
                return .none

            case .setNavigationToSettings(let isActive):
                if !isActive {
                    state.settings = nil
                } else {
                    state.settings = Settings.State()
                }
                return .none

            case .homefeedButtonDidTap:
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

                var showings = apiClient.getShowings()
                showings.sort(by: .date)
                var upcoming = Array(showings.elements.prefix(5)).convertToIdentifiedArray()
                let commonIDs = upcoming.ids.intersection(state.homeFeed.upcoming.ids)
                commonIDs.forEach { upcoming[id: $0] = state.homeFeed.upcoming[id: $0] }
                state.homeFeed.upcoming = upcoming
                return EffectTask.task { .schedule(.filterDatasource) }

            case .endTransition:
                state.isFetching = false
                state.homeFeed.isTransitioning  = false
                state.schedule.isTransitioning = false
                if state.shouldAskForReview {
                    state.shouldAskForReview = false
                    return askForReview()
                } else {
                    return .none
                }
            }
        }
        .ifLet(\.settings, action: /Action.settings) {
            Settings()
        }
    }

    private func askForReview() -> EffectTask<Action> {
        EffectTask.fireAndForget {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            guard let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            await SKStoreReviewController.requestReview(in: scene)
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
            try await mainQueue.sleep(for: .nanoseconds(50_000_000))
            await send(.beginTransition)
            try await mainQueue.sleep(for: .nanoseconds(300_000_000))
            await send(.updateDatasource)
            try await mainQueue.sleep(for: .nanoseconds(100_000_000))
            await send(.endTransition)
        }
        .cancellable(id: CancelID.transition, cancelInFlight: true)
    }
}
