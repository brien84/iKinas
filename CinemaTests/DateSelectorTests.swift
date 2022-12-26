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

    func testDateSelectorInitializesWithExpectedProperties() async {
        let store = TestStore(
            initialState: DateSelector.State(),
            reducer: DateSelector()
        )

        XCTAssertTrue(Calendar.current.isDate(Date(), inSameDayAs: store.state.today))
        XCTAssertEqual(store.state.today, store.state.selectedDate)
        XCTAssertFalse(store.state.restOfTheWeek.contains(store.state.today))
        XCTAssertTrue(store.state.isTodaySelected)
        XCTAssertEqual(store.state.restOfTheWeek.count, 7)

        for index in 0..<store.state.restOfTheWeek.count {
            XCTAssertEqual(
                store.state.restOfTheWeek[index],
                Calendar.current.date(byAdding: .day, value: index + 1, to: store.state.today)
            )
        }
    }

    func testTogglingIsDisabledProperty() async {
        let store = TestStore(
            initialState: DateSelector.State(),
            reducer: DateSelector()
        )

        let isDisabled = store.state.isDisabled

        await store.send(.setDisabled(!isDisabled)) {
            $0.isDisabled = !isDisabled
        }
    }

}
