//
//  MovieListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-17.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

final class MovieListHost: UIHostingController<MovieListView> {
    let viewStore: ViewStoreOf<MovieList>

    required init?(coder aDecoder: NSCoder) {
        let store = Store(initialState: MovieList.State(), reducer: MovieList())
        self.viewStore = ViewStore(store)

        super.init(
            coder: aDecoder,
            rootView: MovieListView(store: store)
        )
    }

}

struct MovieListView: View {
    let store: StoreOf<MovieList>

    var body: some View {
        WithViewStore(store) { _ in
            GeometryReader { proxy in
                ZStack {
                    Color.primaryBackground

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEachStore(
                                store.scope(state: \.movieItems, action: MovieList.Action.movieItem(id:action:))
                            ) {
                                MovieItemView(store: $0)
                                    .frame(width: proxy.size.height / .heightMultiplier, height: proxy.size.height)
                            }
                        }
                        .padding(.horizontal, .horizontalPadding)
                    }
                }
            }
        }
    }
}

private extension CGFloat {
    static let heightMultiplier: CGFloat = 1.5
    static let horizontalPadding: CGFloat = 8
}

// MARK: - Previews

struct MovieListView_Previews: PreviewProvider {
    static let movies = Array(repeating: Movie(), count: 5)

    static let store = Store(
        initialState: MovieList.State(movies: movies),
        reducer: MovieList()
    )

    static var previews: some View {
        MovieListView(store: store)
            .frame(height: 300)
            .preferredColorScheme(.dark)
    }
}

private extension MovieList.State {
    init(movies: [Movie]) {
        self.movieItems = IdentifiedArray(uniqueElements: movies.map { MovieItem.State(id: UUID(), movie: $0) })
    }
}
