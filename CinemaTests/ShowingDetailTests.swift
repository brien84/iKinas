//
//  ShowingDetailTests.swift
//  CinemaTests
//
//  Created by Marius on 2023-01-13.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class ShowingDetailTests: XCTestCase {

    func testSelectingDate() async {
        let showings = [Showing(), Showing(date: Date(timeIntervalSinceNow: 2 * 86400))]

        let store = TestStore(
            initialState: ShowingDetail.State(movie: Movie(showings: showings)),
            reducer: ShowingDetail()
        )

        let date = store.state.dates.last!

        await store.send(.didSelectDate(date)) {
            $0.selectedDate = date
        }
    }

}
