//
//  MovieInfo.swift
//  Cinema
//
//  Created by Marius on 2022-12-29.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieInfo: ReducerProtocol {
    struct State: Equatable {
        var showing: Showing.State
        var showingTimes: ShowingTimes.State?

        var isScrollingEnabled = true
        let shouldDisplayTicketURL: Bool
        var showingURL: URL?
        var titleViewOverlapPercentage: CGFloat = 0

        var isNavigationToShowingTimesActive = false

        init(showing: Showing.State, shouldDisplayTicketURL: Bool) {
            self.showing = showing
            self.shouldDisplayTicketURL = shouldDisplayTicketURL
        }
    }

    enum Action: Equatable {
        case networkImage(NetworkImage.Action)
        case showingTimes(ShowingTimes.Action)

        case setShowingURL(URL?)
        case toggleScrolling(isEnabled: Bool)
        case updateTitleViewOverlap(percentage: CGFloat)

        case setNavigationToShowingTimes(isActive: Bool)
    }

    @Dependency(\.apiClient) var apiClient

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.showing.networkImage, action: /Action.networkImage) {
            NetworkImage()
        }

        Reduce { state, action in
            switch action {

            case .showingTimes(.didSelectShowing(let showing)):
                state.isNavigationToShowingTimesActive = false
                state.showingURL = showing.url
                return .none

            case .showingTimes(.exitButtonDidTap):
                state.isNavigationToShowingTimesActive = false
                return .none

            case .showingTimes:
                return .none

            case .networkImage:
                return .none

            case .setShowingURL(let url):
                state.showingURL = url
                return .none

            case .toggleScrolling(isEnabled: let isEnabled):
                state.isScrollingEnabled = isEnabled
                return .none

            case .updateTitleViewOverlap(percentage: let percentage):
                state.titleViewOverlapPercentage = percentage
                return .none

            case .setNavigationToShowingTimes(isActive: let isActive):
                if isActive {
                    state.isNavigationToShowingTimesActive = true

                    var showings = apiClient.getShowings().filter(by: state.showing.title)
                    showings.sort(by: .date)

                    state.showingTimes = ShowingTimes.State(showings: showings)
                } else {
                    state.isNavigationToShowingTimesActive = false
                }

                return .none

            }
        }
        .ifLet(\.showingTimes, action: /Action.showingTimes) {
            ShowingTimes()
        }
    }
}
