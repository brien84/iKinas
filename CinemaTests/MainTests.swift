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

    func testChangingSelectedDate() async {
        let store = TestStore(
            initialState: Main.State(),
            reducer: Main()
        )

        let date = store.state.dateSelector.today

        await store.send(.dateSelector(.didSelect(date: date))) {
            $0.schedule.datasource.date = date
            $0.dateSelector.isDisabled = true
        }
    }

    func testSelectingMovie() async {
        let movie = Movie()
        let movieItems = IdentifiedArray(uniqueElements: [MovieItem.State(id: movie.id, movie: movie)])

        let store = TestStore(
            initialState: Main.State(schedule: Schedule.State(movieItems: movieItems)),
            reducer: Main()
        )

        await store.send(.schedule(.movieItem(id: movie.id, action: .didSelectMovie(movie)))) {
            $0.movieDetail = MovieDetail.State(movie: movie, showing: nil)
        }
    }

    func testSelectingShowing() async {
        let showing = Showing()
        let movie = Movie(showings: [showing])
        let showingItems = IdentifiedArray(uniqueElements: [ShowingItem.State(id: showing.id, showing: showing)])

        let store = TestStore(
            initialState: Main.State(schedule: Schedule.State(showingItems: showingItems)),
            reducer: Main()
        )

        await store.send(.schedule(.showingItem(id: showing.id, action: .didSelectShowing(showing)))) {
            $0.movieDetail = MovieDetail.State(movie: movie, showing: showing)
        }
    }

    func testHandlingSettingsButtonTap() async {
        let store = TestStore(
            initialState: Main.State(),
            reducer: Main()
        )

        await store.send(.schedule(.settingsButtonDidTap)) {
            $0.settings = Settings.State()
        }
    }

    func testHandlingEndOfScheduleTransition() async {
        let store = TestStore(
            initialState: Main.State(),
            reducer: Main()
        )

        await store.send(.schedule(.transitionDidEnd)) {
            $0.dateSelector.isDisabled = false
            $0.requiresToFetchMovies = false
        }
    }

    func testSavingSettingsRefetchesMovies() async {
        let store = TestStore(
            initialState: Main.State(
                settings: Settings.State(),
                requiresToFetchMovies: false
            ),
            reducer: Main()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        let movies = [Movie()]
        store.dependencies.movieClient.fetch = { Effect(value: movies) }

        store.dependencies.userDefaults.setCity = { _ in }
        store.dependencies.userDefaults.setVenues = { _ in }

        await store.send(.settings(.saveSettings)) {
            $0.requiresToFetchMovies = true
            $0.movieClientError = nil
        }

        await mainQueue.advance(by: .seconds(1))

        await store.receive(.movieClient(.success(movies))) {
            $0.schedule.datasource.movies = movies
            $0.schedule.didUpdateDatasource = true
            $0.dateSelector.isDisabled = true
        }
    }

    func testFetchingMoviesSuccessfully() async {
        let store = TestStore(
            initialState: Main.State(
                movieClientError: .network,
                requiresToFetchMovies: false
            ),
            reducer: Main()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        let movies = [Movie()]
        store.dependencies.movieClient.fetch = { Effect(value: movies) }

        await store.send(.fetchMovies) {
            $0.requiresToFetchMovies = true
            $0.movieClientError = nil
        }

        await mainQueue.advance(by: .seconds(1))

        await store.receive(.movieClient(.success(movies))) {
            $0.schedule.datasource.movies = movies
            $0.schedule.didUpdateDatasource = true
            $0.dateSelector.isDisabled = true
        }
    }

    func testEncounteringNetworkErrorWhileFetchingMovies() async {
        let store = TestStore(
            initialState: Main.State(
                movieClientError: .network,
                requiresToFetchMovies: false
            ),
            reducer: Main()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        store.dependencies.movieClient.fetch = {
            Effect(error: .network)
        }

        await store.send(.fetchMovies) {
            $0.requiresToFetchMovies = true
            $0.movieClientError = nil
        }

        await mainQueue.advance(by: .seconds(1))

        await store.receive(.movieClient(.failure(.network))) {
            $0.movieClientError = .network
        }
    }

    func testEncounteringRequiresUpdateErrorWhileFetchingMovies() async {
        let store = TestStore(
            initialState: Main.State(
                movieClientError: .network,
                requiresToFetchMovies: false
            ),
            reducer: Main()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        store.dependencies.movieClient.fetch = {
            Effect(error: .requiresUpdate)
        }

        await store.send(.fetchMovies) {
            $0.requiresToFetchMovies = true
            $0.movieClientError = nil
        }

        await mainQueue.advance(by: .seconds(1))

        await store.receive(.movieClient(.failure(.requiresUpdate))) {
            $0.movieClientError = .requiresUpdate
        }
    }

    func testNavigationToMovieDetail() async {
        let store = TestStore(
            initialState: Main.State(movieDetail: MovieDetail.State(movie: Movie())),
            reducer: Main()
        )

        await store.send(.setNavigationToMovieDetail(isActive: false)) {
            $0.movieDetail = nil
        }
    }

    func testNavigationToSettings() async {
        let store = TestStore(
            initialState: Main.State(),
            reducer: Main()
        )

        await store.send(.setNavigationToSettings(isActive: true)) {
            $0.settings = Settings.State()
        }

        await store.send(.setNavigationToSettings(isActive: false)) {
            $0.settings = nil
        }
    }

}
