//
//  DateSelector.swift
//  Cinema
//
//  Created by Marius on 2022-12-15.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct DateSelector: ReducerProtocol {
    struct State: Equatable {
        let dates: [Date]
        var selectedDate: Date

        init(dates: [Date], selectedDate: Date) {
            self.dates = dates
            self.selectedDate = selectedDate
        }

        init(dates: [Date]) {
            self.dates = dates

            if let date = dates.first {
                self.selectedDate = date
            } else {
                self.selectedDate = Date()
            }
        }
    }

    enum Action: Equatable {
        case didSelect(date: Date)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .didSelect(date: let date):
            assert(
                state.dates.contains(date),
                """
                The selected date '\(date)' is not found in `state.dates` array,
                and may cause unpredictable app behavior.
                """
            )

            state.selectedDate = date

            return .none
        }
    }
}
