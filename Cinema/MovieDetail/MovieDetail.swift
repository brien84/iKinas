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
        let movie: Movie
        let showing: Showing?
        var showingDetail: ShowingDetail.State?
        var networkImage: NetworkImage.State

        // The percentage of the `TitleView` that is overlapped by the navigation bar.
        var titleViewOverlapPercentage: CGFloat = 0

        init(movie: Movie, showing: Showing? = nil) {
            self.movie = movie
            self.showing = showing
            self.networkImage = NetworkImage.State(url: movie.poster)
        }
    }

    enum Action: Equatable {
        case networkImage(NetworkImage.Action)
        case showingDetail(ShowingDetail.Action)
        case toggleShowingDetail
        case updateTitleViewOverlap(percentage: CGFloat)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.networkImage, action: /Action.networkImage) {
            NetworkImage()
        }

        Reduce { state, action in
            switch action {
            case .networkImage:
                return .none

            case .showingDetail:
                return .none

            case .toggleShowingDetail:
                if state.showingDetail == nil {
                    state.showingDetail = ShowingDetail.State(movie: state.movie)
                } else {
                    state.showingDetail = nil
                }
                return .none

            case .updateTitleViewOverlap(percentage: let percentage):
                state.titleViewOverlapPercentage = percentage
                return .none
            }
        }
        .ifLet(\.showingDetail, action: /Action.showingDetail) {
            ShowingDetail()
        }
    }

}
