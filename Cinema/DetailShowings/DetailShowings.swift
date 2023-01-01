//
//  DetailShowings.swift
//  Cinema
//
//  Created by Marius on 2022-12-30.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct DetailShowings: ReducerProtocol {

    struct Section: Equatable, Identifiable {
        let id = UUID()
        let date: Date

        init(date: Date) {
            self.date = date
        }
    }

    struct State: Equatable {
        let sections: IdentifiedArrayOf<Section>
        var selectedSection: Section?

        init(movie: Movie) {
            let allDates = movie.showings.compactMap { showing -> Date? in
                guard showing.date > Date() else { return nil }
                return Calendar.current.startOfDay(for: showing.date)
            }

            var uniqueDates = Array(Set(allDates)).sorted()

            if uniqueDates.count > 8 {
                uniqueDates = Array(uniqueDates.dropLast(uniqueDates.count - 8))
            }

            let sections = uniqueDates.map { date in
                Section(date: date)
            }.sorted(by: { $0.date < $1.date })

            self.sections = IdentifiedArrayOf(uniqueElements: sections)
            self.selectedSection = sections.first
        }
    }

    enum Action: Equatable {
        case didSelectSection(Section)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didSelectSection(let section):
                state.selectedSection = section
                return .none
            }
        }
    }

}
