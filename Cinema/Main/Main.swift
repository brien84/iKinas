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
        var dateSelector = DateSelector.State()
        var settings: Settings.State?

        var isNavigationToSettingsActive: Bool {
            settings != nil
        }
    }

    enum Action: Equatable {
        case dateSelector(action: DateSelector.Action)
        case settings(action: Settings.Action)
        case setNavigationToSettings(isActive: Bool)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.movieClient) var movieClient

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.dateSelector, action: /Action.dateSelector) {
            DateSelector()
        }

        Reduce { state, action in
            switch action {

            case .dateSelector:
                return .none

            case .settings:
                return .none

            case .setNavigationToSettings(let isActive):
                state.settings = isActive ? Settings.State() : nil
                return .none

            }
        }
        .ifLet(\.settings, action: /Action.settings) {
            Settings()
        }

    }
}
