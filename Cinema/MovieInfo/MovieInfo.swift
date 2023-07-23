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
        var movieShowings: MovieShowings.State?
        var networkImage: NetworkImage.State

        var isScrollingEnabled = true
        let showing: Showing
        let shouldDisplayURL: Bool
        var showingURL: URL?
        var titleViewOverlapPercentage: CGFloat = 0

        var isNavigationToMovieShowingsActive = false

        init(showing: Showing, shouldDisplayURL: Bool) {
            self.showing = showing
            self.shouldDisplayURL = shouldDisplayURL
            self.networkImage = NetworkImage.State(url: showing.posterURL)
        }
    }

    enum Action: Equatable {
        case movieShowings(MovieShowings.Action)
        case networkImage(NetworkImage.Action)

        case setShowingURL(URL?)
        case toggleScrolling(isEnabled: Bool)
        case updateTitleViewOverlap(percentage: CGFloat)

        case setNavigationToMovieShowings(isActive: Bool)
    }

    @Dependency(\.apiClient) var apiClient

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.networkImage, action: /Action.networkImage) {
            NetworkImage()
        }

        Reduce { state, action in
            switch action {

            case .movieShowings(.didSelectShowing(let showing)):
                state.isNavigationToMovieShowingsActive = false
                state.showingURL = showing.url
                return .none

            case .movieShowings(.exitButtonDidTap):
                state.isNavigationToMovieShowingsActive = false
                return .none

            case .movieShowings:
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

            case .setNavigationToMovieShowings(isActive: let isActive):
                if isActive {
                    state.isNavigationToMovieShowingsActive = true

                    let showings = apiClient.getShowings().filter { showing in
                        showing.title == state.showing.title
                    }

                    state.movieShowings = MovieShowings.State(showings: showings)
                } else {
                    state.isNavigationToMovieShowingsActive = false
                }

                return .none

            }
        }
        .ifLet(\.movieShowings, action: /Action.movieShowings) {
            MovieShowings()
        }
    }
}
