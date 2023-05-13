//
//  MovieListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-17.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

private extension MovieListView {
    struct State: Equatable {
        var isTransitioning = false
        var movieItems: IdentifiedArrayOf<MovieItem.State> = []
    }

    enum Action: Equatable {
        case movieItem(id: MovieItem.State.ID, action: MovieItem.Action)
    }
}

private extension Schedule.State {
    var state: MovieListView.State {
        .init(isTransitioning: self.isTransitioning, movieItems: self.movieItems)
    }
}

private extension MovieListView.Action {
    var action: Schedule.Action {
        switch self {
        case .movieItem(let id, let action):
            return .movieItem(id: id, action: action)
        }
    }
}

struct MovieListView: View {
    let store: StoreOf<Schedule>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            GeometryReader { proxy in
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEachStore(store.scope(
                                state: \.movieItems,
                                action: Schedule.Action.movieItem(id:action:)
                            )) {
                                MovieItemView(store: $0)
                                    .frame(
                                        width: proxy.size.height / Self.widthToHeightRatio,
                                        height: proxy.size.height
                                    )
                            }
                        }
                        .padding(.horizontal)
                        .id(Self.scrollToTopID)
                    }
                    .background(Color.primaryBackground)
                    .onChange(of: viewStore.isTransitioning) { newValue in
                        guard newValue else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + Self.scrollToTopDelay) {
                            scrollProxy.scrollTo(Self.scrollToTopID, anchor: .leading)
                        }
                    }
                }
           }
        }
    }
}

// MARK: - Constants

private extension MovieListView {
    static let scrollToTopDelay: CGFloat = 0.3
    static let scrollToTopID: String = "upandaway"
    static let widthToHeightRatio: CGFloat = 1.5
}

// MARK: - Previews

struct MovieListView_Previews: PreviewProvider {
    static let items = {
        let movies = Array(repeating: Movie(), count: 5)
        return IdentifiedArray(uniqueElements: movies.map { MovieItem.State(id: UUID(), movie: $0) })
    }()

    static let store = Store(
        initialState: Schedule.State(movieItems: items),
        reducer: Schedule()
    )

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            MovieListView(store: store)
                .frame(height: 300)
                .preferredColorScheme(.dark)
        }
    }
}
