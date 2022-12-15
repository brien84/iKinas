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
        var selected: Date

        init() {
            var dates = [Date]()
            let now = Date()
            for index in 0..<8 {
                guard let date = Calendar.current.date(byAdding: .day, value: index, to: now)
                else { fatalError("Date generation failed!") }
                dates.append(date)
            }

            self.dates = dates
            self.selected = dates[0]
        }
    }

    enum Action: Equatable {
        case didSelect(date: Date)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .didSelect(date: let date):
            state.selected = date
            return .none
        }
    }
}
