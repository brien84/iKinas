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
            $0.isFetchingMovies = false
        }
    }

    func testSavingSettingsRefetchesMovies() async {
        let store = TestStore(
            initialState: Main.State(
                settings: Settings.State(),
                isFetchingMovies: false
            ),
            reducer: Main()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        let movies = [Movie()]
        store.dependencies.movieClient.fetch = { _, _ in Effect(value: movies) }

        store.dependencies.userDefaults.getCity = { City.vilnius }
        store.dependencies.userDefaults.getVenues = { City.vilnius.venues }
        store.dependencies.userDefaults.setCity = { _ in }
        store.dependencies.userDefaults.setVenues = { _ in }

        await store.send(.settings(.saveSettings)) {
            $0.isFetchingMovies = true
            $0.movieClientError = nil
        }

        await mainQueue.advance(by: .seconds(1))

        await store.receive(.movieClient(.success(movies))) {
            $0.schedule.datasource.movies = movies
            $0.schedule.didUpdateDatasource = true
        }
    }

    func testFetchingMoviesSuccessfully() async {
        let store = TestStore(
            initialState: Main.State(
                movieClientError: .network
            ),
            reducer: Main()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        let movies = [Movie()]
        store.dependencies.movieClient.fetch = { _, _ in Effect(value: movies) }

        store.dependencies.userDefaults.getCity = { City.vilnius }
        store.dependencies.userDefaults.getVenues = { City.vilnius.venues }

        await store.send(.fetchMovies) {
            $0.isFetchingMovies = true
            $0.movieClientError = nil
        }

        await mainQueue.advance(by: .seconds(1))

        await store.receive(.movieClient(.success(movies))) {
            $0.schedule.datasource.movies = movies
            $0.schedule.didUpdateDatasource = true
        }
    }

    func testEncounteringNetworkErrorWhileFetchingMovies() async {
        let store = TestStore(
            initialState: Main.State(
                movieClientError: .network
            ),
            reducer: Main()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        store.dependencies.movieClient.fetch = { _, _ in
            Effect(error: .network)
        }

        store.dependencies.userDefaults.getCity = { City.vilnius }
        store.dependencies.userDefaults.getVenues = { City.vilnius.venues }

        await store.send(.fetchMovies) {
            $0.isFetchingMovies = true
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
                movieClientError: .network
            ),
            reducer: Main()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        store.dependencies.movieClient.fetch = { _, _ in
            Effect(error: .requiresUpdate)
        }

        store.dependencies.userDefaults.getCity = { City.vilnius }
        store.dependencies.userDefaults.getVenues = { City.vilnius.venues }

        await store.send(.fetchMovies) {
            $0.isFetchingMovies = true
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
