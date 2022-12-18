//
//  MovieItem.swift
//  Cinema
//
//  Created by Marius on 2022-12-17.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct MovieItem: ReducerProtocol {

    struct State: Equatable, Identifiable {
        let id: UUID
        let movie: Movie
        var networkImage: NetworkImage.State

        init(id: UUID, movie: Movie) {
            self.id = id
            self.movie = movie
            self.networkImage = NetworkImage.State(url: movie.poster)
        }
    }

    enum Action: Equatable {
        case didSelectMovie(Movie)
        case networkImage(NetworkImage.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.networkImage, action: /Action.networkImage) {
            NetworkImage()
        }

        Reduce { _, action in
            switch action {
            case .didSelectMovie:
                return .none
            case .networkImage:
                return .none
            }
        }
    }

}
