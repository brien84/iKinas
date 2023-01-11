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
        var isScrollDisabled = false
        let movie: Movie
        var networkImage: NetworkImage.State
        var openedURL: URL?
        let showing: Showing?
        var showingDetail: ShowingDetail.State?
        var isShowingDetailPresented = false

        // The percentage of the `TitleView` that is overlapped by the navigation bar.
        var titleViewOverlapPercentage: CGFloat = 0

        init(movie: Movie, showing: Showing? = nil) {
            self.movie = movie
            self.showing = showing
            self.networkImage = NetworkImage.State(url: movie.poster)
        }
    }

    enum Action: Equatable {
        case toggleScrollDisabled(Bool)
        case networkImage(NetworkImage.Action)
        case openURL(URL?)
        case showingDetail(ShowingDetail.Action)
        case updateTitleViewOverlap(percentage: CGFloat)
        case setShowingDetail(isPresented: Bool)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.networkImage, action: /Action.networkImage) {
            NetworkImage()
        }

        Reduce { state, action in
            switch action {
            case .toggleScrollDisabled(let isDisabled):
                state.isScrollDisabled = isDisabled
                return .none

            case .networkImage:
                return .none

            case .openURL(let url):
                state.openedURL = url
                return .none

            case .showingDetail(.didSelectShowing(let showing)):
                state.isShowingDetailPresented = false
                state.openedURL = showing.url
                return .none

            case .showingDetail(.exitButtonDidTap):
                state.isShowingDetailPresented = false
                return .none

            case .showingDetail:
                return .none

            case .setShowingDetail(isPresented: true):
                state.isShowingDetailPresented = true
                state.showingDetail = ShowingDetail.State(movie: state.movie)
                return .none

            case .setShowingDetail(isPresented: false):
                state.isShowingDetailPresented = false
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
