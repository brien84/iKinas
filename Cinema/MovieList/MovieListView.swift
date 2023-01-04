//
//  MovieListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-17.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieListView: View {
    let store: StoreOf<MovieList>

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                ZStack {
                    Color.primaryBackground

                    ScrollViewReader { scrollProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEachStore(
                                    store.scope(state: \.movieItems, action: MovieList.Action.movieItem(id:action:))
                                ) {
                                    MovieItemView(store: $0)
                                        .frame(width: proxy.size.height / Self.widthToHeightRatio, height: proxy.size.height)
                                }
                            }
                            .padding(.horizontal)
                            .id(Self.scrollToTopID)
                        }
                        .onChange(of: viewStore.requiresScrollToTop) { newValue in
                            if newValue {
                                scrollProxy.scrollTo(Self.scrollToTopID, anchor: .leading)
                            }
                        }
                    }

                }
            }
        }
    }
}

// MARK: - Constants

private extension MovieListView {
    static let scrollToTopID: String = "upandaway"
    static let widthToHeightRatio: CGFloat = 1.5
}

// MARK: - Previews

struct MovieListView_Previews: PreviewProvider {
    static let movies = Array(repeating: Movie(), count: 5)

    static let store = Store(
        initialState: MovieList.State(movies: movies),
        reducer: MovieList()
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

private extension MovieList.State {
    init(movies: [Movie]) {
        self.movieItems = IdentifiedArray(uniqueElements: movies.map { MovieItem.State(id: UUID(), movie: $0) })
    }
}
