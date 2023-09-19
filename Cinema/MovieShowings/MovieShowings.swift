//
//  MovieShowings.swift
//  Cinema
//
//  Created by Marius on 2023-01-05.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct MovieShowings: ReducerProtocol {
    struct State: Equatable {
        var dateSelector: DateSelector.State
        let showings: [Showing]

        init(showings: [Showing]) {
            self.dateSelector = DateSelector.State(dates: showings.getDays())
            self.showings = showings
        }
    }

    enum Action: Equatable {
        case dateSelector(DateSelector.Action)
        case didSelectDate(Date)
        case didSelectShowing(Showing)
        case exitButtonDidTap
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.dateSelector, action: /Action.dateSelector) {
            DateSelector()
        }

        Reduce { state, action in
            switch action {
            case .dateSelector:
                return .none

            case .didSelectDate(let date):
                state.dateSelector.selectedDate = date
                return .none

            case .didSelectShowing:
                return .none

            case .exitButtonDidTap:
                return .none
            }
        }
    }
}
