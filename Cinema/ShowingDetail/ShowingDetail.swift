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
        let dates: [Date]
        var selectedDate: Date
        let showings: [Showing]

        init(movie: Movie) {
            self.showings = movie.showings

            let allDates = self.showings.compactMap { showing -> Date? in
                if !CommandLine.isUITesting {
                    guard showing.date > Date() else { return nil }
                }
                return Calendar.current.startOfDay(for: showing.date)
            }

            self.dates = Array(Set(allDates)).sorted()

            if !dates.isEmpty {
                self.selectedDate = dates[0]
            } else {
                self.selectedDate = Date()
            }
        }

        func getShowings(at date: Date) -> IdentifiedArrayOf<Showing> {
            let showings = showings.filter { $0.isShown(on: date) }.sorted()
            return IdentifiedArray(uniqueElements: showings)
        }
    }

    enum Action: Equatable {
        case didSelectDate(Date)
        case didSelectShowing(Showing)
        case exitButtonDidTap
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didSelectDate(let date):
                state.selectedDate = date
                return .none

            case .didSelectShowing:
                return .none

            case .exitButtonDidTap:
                return .none
            }
        }
    }

}
