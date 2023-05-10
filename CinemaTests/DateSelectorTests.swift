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
        let store = TestStore(
            initialState: DateSelector.State(dates: Calendar.current.getNextSevenDays()),
            reducer: DateSelector()
        )

        let date = store.state.dates.last!

        await store.send(.didSelect(date: date)) {
            $0.selectedDate = date
        }
    }

}
