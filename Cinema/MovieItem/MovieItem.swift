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
    }

    enum Action: Equatable {
        case none
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .none:
                return .none
            }
        }
    }
}
