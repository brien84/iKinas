//
//  Main.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture

struct Main: ReducerProtocol {

    struct State: Equatable {

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
