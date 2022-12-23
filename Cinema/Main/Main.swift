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
        var requiresToFetchMovies = true

        var isNavigationToSettingsActive: Bool {
            settings != nil
        }
    }

    enum Action: Equatable {
        case fetchMovies
        case dateSelector(action: DateSelector.Action)
        case movieClient(Result<[Movie], MovieClient.Failure>)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.movieClient) var movieClient

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.dateSelector, action: /Action.dateSelector) {
            DateSelector()
        }

        Reduce { state, action in
            switch action {

            case .fetchMovies:
                return movieClient.fetch()
                    .receive(on: mainQueue)
                    .catchToEffect(Action.movieClient)

            case .dateSelector:
                return .none

            case .settings:
                return .none

            case .setNavigationToSettings(let isActive):
                state.settings = isActive ? Settings.State() : nil
                return .none

            case .movieClient(let result):
                switch result {
                case .success(let movies):
                    let datasource = Schedule.Datasource(
                        date: state.dateSelector.selectedDate,
                        movies: movies
                    )
                    return Effect(value: .schedule(action: .datasourceNeedsUpdate(datasource)))
                case .failure(let error):
                    switch error {
                    case .requiresUpdate:
                        print("requiresUpdate")
                    case .network, .decoding:
                        print("network error!")
                    }
                    return .none
                }

            }
        }
        .ifLet(\.settings, action: /Action.settings) {
            Settings()
        }

    }
}
