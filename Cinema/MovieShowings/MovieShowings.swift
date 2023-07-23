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
        private let showings: [Showing]

        init(showings: [Showing]) {
            self.showings = showings

            let allDates = self.showings.compactMap { showing -> Date? in
                guard showing.date > Date() else { return nil }
                return Calendar.current.startOfDay(for: showing.date)
            }

            let dates = Array(Set(allDates)).sorted()
            self.dateSelector = DateSelector.State(dates: dates)
        }

        func getShowings(at date: Date) -> IdentifiedArrayOf<Showing> {
            let showings = showings.filter { $0.isShown(on: date) }.sorted()
            return IdentifiedArray(uniqueElements: showings)
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
