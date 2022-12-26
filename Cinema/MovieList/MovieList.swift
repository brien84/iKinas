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
        var requiresScrollToTop = false
    }

    enum Action: Equatable {
        case movieItem(id: MovieItem.State.ID, action: MovieItem.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .movieItem:
                return .none
            }
        }
        .forEach(\.movieItems, action: /Action.movieItem(id:action:)) {
            MovieItem()
        }
    }

}
