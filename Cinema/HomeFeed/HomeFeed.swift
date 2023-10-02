//
//  HomeFeed.swift
//  Cinema
//
//  Created by Marius on 2023-04-28.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture

struct HomeFeed: ReducerProtocol {
    struct State: Equatable {
        var isTransitioning = false
    }

    enum Action: Equatable {
        case scheduleButtonDidTap
        case settingsButtonDidTap
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .scheduleButtonDidTap:
                return .none

            case .settingsButtonDidTap:
                return .none
            }
        }
    }
}
