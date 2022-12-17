//
//  MovieItemView.swift
//  Cinema
//
//  Created by Marius on 2022-12-17.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieItemView: View {
    let store: StoreOf<MovieItem>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .foregroundColor(.green)

                VStack {
                    Spacer()

                    LazyVStack(alignment: .leading) {
                        Text(viewStore.movie.title)
                            .lineLimit(1)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(viewStore.movie.originalTitle)
                            .lineLimit(1)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct MovieItemView_Previews: PreviewProvider {
    static let movie = Movie.create(title: "Movie Title", originalTitle: "Movie Title But In Foreign Language")

    static let store = Store(
        initialState: MovieItem.State(id: UUID(), movie: movie),
        reducer: MovieItem()
    )

    static var previews: some View {
        MovieItemView(store: store)
    }
}
