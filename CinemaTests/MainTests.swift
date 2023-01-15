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

        store.dependencies.movieClient.fetch = {
            Effect(value: movies)
        }

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
            initialState: Main.State(settings: Settings.State()),
            reducer: Main()
        )

        await store.send(.setNavigationToSettings(isActive: false)) {
            $0.settings = nil
        }
    }

}
