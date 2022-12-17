//
//  MovieList.swift
//  Cinema
//
//  Created by Marius on 2022-12-16.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture

struct MovieList: ReducerProtocol {
    struct State: Equatable {
        var movies: [Movie]
    }

    enum Action: Equatable {
        case none
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .none:
            return .none
        }
    }
}
