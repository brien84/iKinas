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
        let movie: Movie
        var selectedDate: Date

        init(movie: Movie) {
            let allDates = movie.showings.compactMap { showing -> Date? in
                guard showing.date > Date() else { return nil }
                return Calendar.current.startOfDay(for: showing.date)
            }

            let uniqueDates = Array(Set(allDates)).sorted()

            self.movie = movie
            self.dates = uniqueDates

            if !dates.isEmpty {
                self.selectedDate = dates[0]
            } else {
                self.selectedDate = Date()
            }
        }

        func getShowings(at date: Date) -> IdentifiedArrayOf<Showing> {
            let showings = movie.showings.filter { $0.isShown(on: date) }.sorted()
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
