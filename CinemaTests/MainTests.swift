//
//  MainTests.swift
//  CinemaTests
//
//  Created by Marius on 2022-12-20.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class MainTests: XCTestCase {
    typealias TestMainStore = TestStore<Main.State, Main.Action, Main.State, Main.Action, ()>
    var mainQueue: TestSchedulerOf<DispatchQueue>!

    override func setUp() async throws {
        mainQueue = DispatchQueue.test
    }

    override func tearDown() async throws {
        mainQueue = nil
    }

    func makeTestStore(with state: Main.State) -> TestMainStore {
        let store = TestStore(initialState: state, reducer: Main())

        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        store.dependencies.userDefaults.getCity = { .vilnius }
        store.dependencies.userDefaults.getVenues = { City.vilnius.venues }
        store.dependencies.userDefaults.setCity = { _ in }
        store.dependencies.userDefaults.setVenues = { _ in }
        store.dependencies.userDefaults.shouldAskForReview = { false }

        store.dependencies.apiClient.getShowings = { [] }

        return store
    }

    func testSelectingDate() async {
        let date = Date()
        let dateSelector = DateSelector.State(dates: [date], selectedDate: .none)
        let store = makeTestStore(with: Main.State(dateSelector: dateSelector))
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.dateSelector(.didSelect(date: date))) {
            $0.dateSelector.selectedDate = date
            $0.isHomeFeedButtonSelected = false
        }

        await mainQueue.advance(by: .nanoseconds(50_000_000))

        await store.receive(.beginTransition)

        await mainQueue.advance(by: .nanoseconds(300_000_000))

        await store.receive(.updateDatasource) {
            $0.isHomeFeedActive = false
            $0.schedule.selectedDate = date
        }

        await store.skipReceivedActions()
    }

    func testTappingHomeFeedScheduleButton() async {
        let state = Main.State()
        let store = makeTestStore(with: state)
        store.exhaustivity = .off(showSkippedAssertions: false)

        let showings = stride(from: 1, through: 10, by: 1)
            .map { _ in Previews.createShowing() }
            .convertToIdentifiedArray()

        store.dependencies.apiClient.getShowings = { showings }
        store.dependencies.userDefaults.shouldAskForReview = { true }

        await store.send(.homeFeed(.scheduleButtonDidTap)) {
            $0.isHomeFeedButtonSelected = false
            $0.schedule.isTimeFiltering = false
            $0.dateSelector.selectedDate = showings.getUpcomingDays().first!
            $0.shouldAskForReview = true
        }

        await mainQueue.advance(by: .nanoseconds(50_000_000))

        await store.skipReceivedActions()
    }

    func testTappingHomeFeedSettingsButton() async {
        let store = TestStore(initialState: Main.State(), reducer: Main())

        await store.send(.homeFeed(.settingsButtonDidTap)) {
            $0.settings = Settings.State()
        }
    }

    func testSelectingFeatured() async {
        let featured = Previews.createFeatured(title: "test")
        let homeFeed = HomeFeed.State(featured: [featured].convertToIdentifiedArray())

        let showing = Previews.createShowing(title: "test")
        let schedule = Schedule.State(datasource: [showing].convertToIdentifiedArray())

        let state = Main.State(homeFeed: homeFeed, schedule: schedule)
        let store = TestStore(initialState: state, reducer: Main())

        await store.send(.homeFeed(.featured(id: featured.id, action: .didSelect))) {
            $0.showingInfo = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: false)
        }
    }

    func testSelectingUpcomingShowing() async {
        let showing = Previews.createShowing()
        let homeFeed = HomeFeed.State(upcoming: [showing].convertToIdentifiedArray())

        let state = Main.State(homeFeed: homeFeed)
        let store = TestStore(initialState: state, reducer: Main())

        await store.send(.homeFeed(.upcoming(id: showing.id, action: .didSelect))) {
            $0.showingInfo = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: true)
        }
    }

    func testSelectingMovieItem() async {
        let showing = Previews.createShowing()
        let schedule = Schedule.State(
            datasource: [showing].convertToIdentifiedArray(),
            movies: [showing].convertToIdentifiedArray()
        )

        let state = Main.State(schedule: schedule)
        let store = TestStore(initialState: state, reducer: Main())

        await store.send(.schedule(.movie(id: showing.id, action: .didSelect))) {
            $0.showingInfo = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: false)
        }
    }

    func testSelectingShowingItem() async {
        let showing = Previews.createShowing()
        let schedule = Schedule.State(
            datasource: [showing].convertToIdentifiedArray(),
            showings: [showing].convertToIdentifiedArray()
        )

        let state = Main.State(schedule: schedule)
        let store = TestStore(initialState: state, reducer: Main())

        await store.send(.schedule(.showing(id: showing.id, action: .didSelect))) {
            $0.showingInfo = ShowingInfo.State(showing: showing, shouldDisplayTicketURL: true)
        }
    }

    func testSavingSettingsRefetchesAPI() async {
        let settings = Settings.State()
        let state = Main.State(settings: settings, apiError: .network, isFetching: false)
        let store = makeTestStore(with: state)
        store.exhaustivity = .off(showSkippedAssertions: false)

        store.dependencies.apiClient.fetch = { _, _ in EffectTask(value: .failure(.decoding)) }

        await store.send(.settings(.saveSettings)) {
            $0.isFetching = true
            $0.apiError = nil
        }

        await mainQueue.advance(by: .milliseconds(750))

        await store.skipReceivedActions()
    }

    func testSuccessfulFetching() async {
        let state = Main.State(isFetching: false)
        let store = makeTestStore(with: state)

        let featured = [Previews.createFeatured()].convertToIdentifiedArray()
        let showings = [Previews.createShowing()].convertToIdentifiedArray()

        store.dependencies.apiClient.fetch = { _, _ in EffectTask(value: .success) }
        store.dependencies.apiClient.getFeatured = { featured }
        store.dependencies.apiClient.getShowings = { showings }

        await store.send(.fetch) {
            $0.isFetching = true
        }

        await mainQueue.advance(by: .milliseconds(750))

        await store.receive(.apiClient(.success(.success))) {
            $0.homeFeed.featured = featured
            $0.dateSelector = DateSelector.State(dates: showings.getUpcomingDays())
            $0.schedule.datasource = showings
            $0.schedule.isTimeFiltering = false
        }

        await mainQueue.advance(by: .nanoseconds(50_000_000))

        await store.receive(.beginTransition)

        await mainQueue.advance(by: .nanoseconds(300_000_000))

        await store.receive(.updateDatasource) {
            $0.schedule.selectedDate = $0.dateSelector.selectedDate
            let upcoming = Array(showings.elements.prefix(5)).convertToIdentifiedArray()
            $0.homeFeed.upcoming = upcoming
        }

        await store.receive(.schedule(.filterDatasource))

        await mainQueue.advance(by: .nanoseconds(100_000_000))

        await store.receive(.endTransition) {
            $0.isFetching = false
            $0.homeFeed.isTransitioning = false
            $0.schedule.isTransitioning = false
        }
    }

    func testEncouteringDecodingErrorWhileFetching() async {
        let state = Main.State(isFetching: false)
        let store = makeTestStore(with: state)

        store.dependencies.apiClient.fetch = { _, _ in EffectTask(value: .failure(.decoding)) }

        await store.send(.fetch) {
            $0.isFetching = true
        }

        await mainQueue.advance(by: .milliseconds(750))

        await store.receive(.apiClient(.success(.failure(.decoding)))) {
            $0.apiError = APIClient.Error.network
        }
    }

    func testEncouteringNetworkErrorWhileFetching() async {
        let state = Main.State(isFetching: false)
        let store = makeTestStore(with: state)

        store.dependencies.apiClient.fetch = { _, _ in EffectTask(value: .failure(.network)) }

        await store.send(.fetch) {
            $0.isFetching = true
        }

        await mainQueue.advance(by: .milliseconds(750))

        await store.receive(.apiClient(.success(.failure(.network)))) {
            $0.apiError = APIClient.Error.network
        }
    }

    func testEncouteringRequiresUpdatErrorWhileFetching() async {
        let state = Main.State(isFetching: false)
        let store = makeTestStore(with: state)

        store.dependencies.apiClient.fetch = { _, _ in EffectTask(value: .failure(.requiresUpdate)) }

        await store.send(.fetch) {
            $0.isFetching = true
        }

        await mainQueue.advance(by: .milliseconds(750))

        await store.receive(.apiClient(.success(.failure(.requiresUpdate)))) {
            $0.apiError = APIClient.Error.requiresUpdate
        }
    }

    func testPressingHomeFeedButton() async {
        let dateSelector = DateSelector.State(dates: [Date()], selectedDate: Date())
        let state = Main.State(dateSelector: dateSelector, isHomeFeedActive: false)
        let store = makeTestStore(with: state)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.homefeedButtonDidTap) {
            $0.isHomeFeedButtonSelected = true
            $0.dateSelector.selectedDate = .none
        }

        await mainQueue.advance(by: .nanoseconds(50_000_000))

        await store.receive(.beginTransition)

        await mainQueue.advance(by: .nanoseconds(300_000_000))

        await store.receive(.updateDatasource) {
            $0.isHomeFeedActive = true
            $0.schedule.selectedDate = .none
        }

        await store.skipReceivedActions()
    }
}
