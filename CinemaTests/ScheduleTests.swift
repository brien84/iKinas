//
//  ScheduleTests.swift
//  CinemaTests
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class ScheduleTests: XCTestCase {

    func testApplyingDatasource() async {
        let date = Date()
        let showings = [Showing()]
        let movies = [Movie(showings: showings)]

        let datasource = Schedule.Datasource(
            date: date,
            movies: movies
        )

        let store = TestStore(
            initialState: Schedule.State(datasource: datasource),
            reducer: Schedule()
        )

        store.dependencies.uuid = .incrementing

        await store.send(.applyDatasource) {
            $0.selectedDate = date
            $0.movieItems = [MovieItem.State(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, movie: movies[0])]
            $0.showingItems = [ShowingItem.State(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, showing: showings[0])]
        }
    }

    func testEndingTransition() async {
        let store = TestStore(
            initialState: Schedule.State(didUpdateDatasource: true),
            reducer: Schedule()
        )

        await store.send(.transitionDidEnd) {
            $0.didUpdateDatasource = false
        }
    }

}
