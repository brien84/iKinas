//
//  ShowingDetail.swift
//  Cinema
//
//  Created by Marius on 2023-01-05.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct ShowingDetail: ReducerProtocol {
    struct State: Equatable {
        @BindableState var dateSelector: DateSelector.State
        private let showings: [Showing]

        init(movie: Movie) {
            self.showings = movie.showings

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

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case dateSelector(DateSelector.Action)
        case didSelectShowing(Showing)
        case exitButtonDidTap
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(state: \.dateSelector, action: /Action.dateSelector) {
            DateSelector()
        }

        Reduce { _, action in
            switch action {
            case .binding:
                return .none

            case .dateSelector:
                return .none

            case .didSelectShowing:
                return .none

            case .exitButtonDidTap:
                return .none
            }
        }
    }
}
