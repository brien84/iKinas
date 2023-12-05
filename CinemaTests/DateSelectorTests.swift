//
//  DateSelectorTests.swift
//  CinemaTests
//
//  Created by Marius on 2022-12-15.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class DateSelectorTests: XCTestCase {

    func testSelectingDate() async {
        let dates = stride(from: 0, through: 10, by: 1).map { index in
            Date(timeIntervalSinceNow: .fullDay * index)
        }

        let store = TestStore(
            initialState: DateSelector.State(dates: dates),
            reducer: DateSelector()
        )

        let date = dates[Int.random(in: 0..<dates.count)]

        await store.send(.didSelect(date: date)) {
            $0.selectedDate = date
        }
    }

}
