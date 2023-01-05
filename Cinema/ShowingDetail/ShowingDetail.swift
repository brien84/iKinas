//
//  ShowingDetail.swift
//  Cinema
//
//  Created by Marius on 2023-01-05.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture

struct ShowingDetail: ReducerProtocol {

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
