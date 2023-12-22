//
//  ShowingInfo.swift
//  Cinema
//
//  Created by Marius on 2022-12-29.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import YouTubePlayerKit

struct ShowingInfo: ReducerProtocol {
    struct State: Equatable {
        var showing: Showing.State
        var showingTimes: ShowingTimes.State?
        var similar: IdentifiedArrayOf<Showing.State> = []

        var isScrollingEnabled = true
        let player: YouTubePlayer?
        var trailerThumbnail = NetworkImage.State(url: nil, defaultImage: nil)
        let shouldDisplayTicketURL: Bool
        var showingURL: URL?
        var selectedSimilarShowingID: UUID?
        var titleViewOverlapPercentage: CGFloat = 0

        var isNavigationToShowingTimesActive = false

        init(showing: Showing.State, shouldDisplayTicketURL: Bool) {
            self.showing = showing
            self.shouldDisplayTicketURL = shouldDisplayTicketURL
            if let url = showing.trailer {
                self.player = .init(source: .url(url), configuration: .init(autoPlay: true))
                if let id = player?.source?.id {
                    self.trailerThumbnail.url = URL(string: "https://i.ytimg.com/vi_webp/\(id)/maxres1.webp")
                }
            } else {
                self.player = nil
            }
        }
    }

    enum Action: Equatable {
        case networkImage(NetworkImage.Action)
        case trailerThumbnail(NetworkImage.Action)
        case showingTimes(ShowingTimes.Action)
        case similar(id: Showing.State.ID, action: Showing.Action)

        case resetSelectedSimilarShowingID
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

        Scope(state: \.trailerThumbnail, action: /Action.trailerThumbnail) {
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

            case .similar(id: let id, action: .didSelect):
                state.selectedSimilarShowingID = id
                return .none

            case .similar:
                return .none

            case .networkImage:
                return .none

            case .trailerThumbnail:
                return .none

            case .resetSelectedSimilarShowingID:
                state.selectedSimilarShowingID = nil
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
        .forEach(\.similar, action: /Action.similar(id:action:)) {
            Showing()
        }
        .ifLet(\.showingTimes, action: /Action.showingTimes) {
            ShowingTimes()
        }
    }
}
