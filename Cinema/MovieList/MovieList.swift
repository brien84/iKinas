//
//  MovieList.swift
//  Cinema
//
//  Created by Marius on 2022-12-16.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieList: ReducerProtocol {

    struct State: Equatable {
        var movieItems: IdentifiedArrayOf<MovieItem.State> = []
        var selectedMovie: Movie?
    }

    enum Action: Equatable {
        case didDeselectMovie
        case movieItem(id: MovieItem.State.ID, action: MovieItem.Action)
        case update(movies: [Movie])
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .didDeselectMovie:
                state.selectedMovie = nil
                return .none

            case .movieItem(id: _, action: .didSelectMovie(let movie)):
                state.selectedMovie = movie
                return .none

            case .movieItem:
                return .none

            case .update(movies: let movies):
                state.movieItems = IdentifiedArray(uniqueElements: movies.map { MovieItem.State(id: uuid(), movie: $0) })
                return .none

            }
        }
        .forEach(\.movieItems, action: /Action.movieItem(id:action:)) {
            MovieItem()
        }
    }

}
