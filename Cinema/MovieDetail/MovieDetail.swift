//
//  MovieDetail.swift
//  Cinema
//
//  Created by Marius on 2022-12-29.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieDetail: ReducerProtocol {

    struct State: Equatable {
        var networkImage: NetworkImage.State
        var showingDetail: ShowingDetail.State?

        var isScrollingEnabled = true
        let movie: Movie
        let showing: Showing?
        var showingURL: URL?
        var titleViewOverlapPercentage: CGFloat = 0

        var isNavigationToShowingDetailActive = false

        init(movie: Movie, showing: Showing? = nil) {
            self.movie = movie
            self.showing = showing
            self.networkImage = NetworkImage.State(id: movie.id, url: movie.poster)
        }
    }

    enum Action: Equatable {
        case networkImage(NetworkImage.Action)
        case showingDetail(ShowingDetail.Action)

        case setShowingURL(URL?)
        case toggleScrolling(isEnabled: Bool)
        case updateTitleViewOverlap(percentage: CGFloat)

        case setNavigationToShowingDetail(isActive: Bool)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.networkImage, action: /Action.networkImage) {
            NetworkImage()
        }

        Reduce { state, action in
            switch action {

            case .networkImage:
                return .none

            case .showingDetail(.didSelectShowing(let showing)):
                state.isNavigationToShowingDetailActive = false
                state.showingURL = showing.url
                return .none

            case .showingDetail(.exitButtonDidTap):
                state.isNavigationToShowingDetailActive = false
                return .none

            case .showingDetail:
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

            case .setNavigationToShowingDetail(isActive: let isActive):
                if isActive {
                    state.isNavigationToShowingDetailActive = true
                    state.showingDetail = ShowingDetail.State(movie: state.movie)
                } else {
                    state.isNavigationToShowingDetailActive = false
                }

                return .none

            }
        }
        .ifLet(\.showingDetail, action: /Action.showingDetail) {
            ShowingDetail()
        }
    }

}
