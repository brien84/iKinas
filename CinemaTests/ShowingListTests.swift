//
//  ShowingListTests.swift
//  CinemaTests
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class ShowingListTests: XCTestCase {

    func testUpdatingShowingItems() async {
        let store = TestStore(
            initialState: ShowingList.State(),
            reducer: ShowingList()
        )

        let uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        store.dependencies.uuid = .constant(uuid)

        let movie = Movie()
        let showing = Showing(parentMovie: movie)

        await store.send(.update(showings: [showing])) {
            $0.showingItems = [ShowingItem.State(id: uuid, showing: showing)]
        }
    }

}
