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
        let today: Date
        let restOfTheWeek: [Date]
        var selectedDate: Date
        var isDisabled = false

        var isTodaySelected: Bool {
            today == selectedDate
        }

        init() {
            self.today = Date()
            self.selectedDate = self.today

            var restOfTheWeek = [Date]()

            for index in 1..<8 {
                guard let date = Calendar.current.date(byAdding: .day, value: index, to: self.today)
                else { fatalError("Date generation failed!") }
                restOfTheWeek.append(date)
            }

            self.restOfTheWeek = restOfTheWeek
        }
    }

    enum Action: Equatable {
        case didSelect(date: Date)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .didSelect(date: let date):
            assert(
                state.today == date || state.restOfTheWeek.contains(date),
                """
                The selected date '\(date)' is not equal to `state.today` or found in
                `state.restOfTheWeek` array, and may cause unpredictable app behavior.
                """
            )

            state.selectedDate = date

            return .none
        }
    }

}
