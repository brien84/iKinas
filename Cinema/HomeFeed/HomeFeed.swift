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
        var showings: IdentifiedArrayOf<Showing.State> = []
    }

    enum Action: Equatable {
        case settingsButtonDidTap
        case scheduleButtonDidTap
        case showing(id: Showing.State.ID, action: Showing.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .scheduleButtonDidTap:
                return .none

            case .settingsButtonDidTap:
                return .none

            case .showing:
                return .none
            }
        }
        .forEach(\.showings, action: /Action.showing(id:action:)) {
            Showing()
        }
    }
}
