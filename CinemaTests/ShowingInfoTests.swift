//
//  ShowingInfoTests.swift
//  CinemaTests
//
//  Created by Marius on 2023-01-13.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class ShowingInfoTests: XCTestCase {

    func testSelectingShowingTime() async {
        let showing = Previews.createShowing(url: URL(string: "test.url")!)
        var state = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: true)
        state.isNavigationToShowingTimesActive = true
        state.showingTimes = .init(showings: [showing].convertToIdentifiedArray())
        let store = TestStore(initialState: state, reducer: ShowingInfo())

        await store.send(.showingTimes(.didSelectShowing(showing))) {
            $0.isNavigationToShowingTimesActive = false
            $0.showingURL = showing.url
        }
    }

    func testExitingShowingTimesByTappingExitButton() async {
        let showing = Previews.createShowing()
        var state = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: true)
        state.isNavigationToShowingTimesActive = true
        state.showingTimes = .init(showings: [showing].convertToIdentifiedArray())
        let store = TestStore(initialState: state, reducer: ShowingInfo())

        await store.send(.showingTimes(.exitButtonDidTap)) {
            $0.isNavigationToShowingTimesActive = false
        }
    }

    func testSelectingSimilarShowingSetsID() async {
        let showing = Previews.createShowing()
        let similar = [Previews.createShowing()].convertToIdentifiedArray()
        var state = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: true)
        state.similar = similar

        let store = TestStore(initialState: state, reducer: ShowingInfo())

        await store.send(.similar(id: similar.first!.id, action: .didSelect)) {
            $0.selectedSimilarShowingID = similar.first!.id
        }

        await store.send(.resetSelectedSimilarShowingID) {
            $0.selectedSimilarShowingID = nil
        }
    }

    func testSettingShowingURL() async {
        let showing = Previews.createShowing()
        let state = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: true)
        let store = TestStore(initialState: state, reducer: ShowingInfo())

        await store.send(.setShowingURL(showing.url)) {
            $0.showingURL = showing.url
        }
    }

    func testTogglingScrolling() async {
        let state = ShowingInfo.State(showing: Previews.createShowing(), shouldDisplayTicketURL: true)
        let store = TestStore(initialState: state, reducer: ShowingInfo())

        await store.send(.toggleScrolling(isEnabled: false)) {
            $0.isScrollingEnabled = false
        }

        await store.send(.toggleScrolling(isEnabled: true)) {
            $0.isScrollingEnabled = true
        }
    }

    func testUpdatingTitleViewOverlapPercentage() async {
        let state = ShowingInfo.State(showing: Previews.createShowing(), shouldDisplayTicketURL: true)
        let store = TestStore(initialState: state, reducer: ShowingInfo())

        await store.send(.updateTitleViewOverlap(percentage: 0.67)) {
            $0.titleViewOverlapPercentage = 0.67
        }
    }

    func testNavigationToShowingTimes() async {
        let showings = [
            Previews.createShowing(title: "TestTitle0"),
            Previews.createShowing(title: "TestTitle1"),
            Previews.createShowing(title: "TestTitle0"),
            Previews.createShowing(title: "TestTitle1"),
            Previews.createShowing(title: "TestTitle0")
        ].convertToIdentifiedArray()

        let state = ShowingInfo.State(showing: showings.first!, shouldDisplayTicketURL: true)
        let store = TestStore(initialState: state, reducer: ShowingInfo())

        store.dependencies.apiClient.getShowings = { showings }

        await store.send(.setNavigationToShowingTimes(isActive: true)) {
            $0.isNavigationToShowingTimesActive = true
            $0.showingTimes = ShowingTimes.State(showings: [showings[0], showings[2], showings[4]])
        }

        await store.send(.setNavigationToShowingTimes(isActive: false)) {
            $0.isNavigationToShowingTimesActive = false
        }
    }

}
