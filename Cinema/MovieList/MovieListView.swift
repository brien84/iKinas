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
        WithViewStore(store) { _ in

            ZStack {
                Color.primaryBackground

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        Color.blue
                    }
                    .padding(.horizontal, 8)
                }
            }

        }
    }
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
