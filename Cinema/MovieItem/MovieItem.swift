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

        init(id: UUID, movie: Movie) {
            self.id = id
            self.movie = movie
        }
    }

    enum Action: Equatable {
        case didSelectMovie(Movie)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didSelectMovie:
                return .none
            }
        }
    }

}
