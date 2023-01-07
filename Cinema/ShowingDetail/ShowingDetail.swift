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

    struct ShowingItem: Equatable, Identifiable {
        let id: UUID = UUID()
        let showing: Showing
    }

    struct State: Equatable {
        let dates: [Date]
        let movie: Movie
        var selectedDate: Date
        var showingItems: IdentifiedArrayOf<ShowingItem>

        init(movie: Movie) {
            let allDates = movie.showings.compactMap { showing -> Date? in
                guard showing.date > Date() else { return nil }
                return Calendar.current.startOfDay(for: showing.date)
            }

            let uniqueDates = Array(Set(allDates)).sorted()

            self.movie = movie
            self.dates = uniqueDates
            self.selectedDate = dates[0]

            let showings = movie.showings.filter { $0.isShown(on: uniqueDates[0]) }.sorted()
            self.showingItems = IdentifiedArray(uniqueElements: showings.map { ShowingItem(showing: $0) })
        }
    }

    enum Action: Equatable {
        case didSelectDate(Date)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didSelectDate(let date):
                state.selectedDate = date
                let showings = state.movie.showings.filter { $0.isShown(on: date) }.sorted()
                state.showingItems = IdentifiedArray(uniqueElements: showings.map { ShowingItem(showing: $0) })
                return .none
            }
        }
    }

}
