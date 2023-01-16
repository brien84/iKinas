//
//  MovieDetailTests.swift
//  CinemaTests
//
//  Created by Marius on 2023-01-13.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class MovieDetailTests: XCTestCase {

    func testTogglingScrolling() async {
        let store = TestStore(
            initialState: MovieDetail.State(movie: Movie()),
            reducer: MovieDetail()
        )

        await store.send(.toggleScrolling(isEnabled: false)) {
            $0.isScrollingEnabled = false
        }

        await store.send(.toggleScrolling(isEnabled: true)) {
            $0.isScrollingEnabled = true
        }
    }

    func testSettingShowingURL() async {
        let showing = Showing()
        let movie = Movie(showings: [showing])

        let store = TestStore(
            initialState: MovieDetail.State(movie: movie),
            reducer: MovieDetail()
        )

        await store.send(.setShowingURL(showing.url)) {
            $0.showingURL = showing.url
        }
    }

    func testSelectingShowing() async {
        let showing = Showing()
        let movie = Movie(showings: [showing])

        let store = TestStore(
            initialState: MovieDetail.State(movie: movie),
            reducer: MovieDetail()
        )

        await store.send(.setNavigationToShowingDetail(isActive: true)) {
            $0.isNavigationToShowingDetailActive = true
            $0.showingDetail = ShowingDetail.State(movie: movie)
            $0.showingDetail?.selectedDate = Calendar.current.startOfDay(for: showing.date)
        }

        await store.send(.showingDetail(.didSelectShowing(showing))) {
            $0.isNavigationToShowingDetailActive = false
            $0.showingURL = showing.url
        }
    }

    func testTappingShowingDetailExitButton() async {
        let showing = Showing()
        let movie = Movie(showings: [showing])

        let store = TestStore(
            initialState: MovieDetail.State(movie: movie),
            reducer: MovieDetail()
        )

        await store.send(.setNavigationToShowingDetail(isActive: true)) {
            $0.isNavigationToShowingDetailActive = true
            $0.showingDetail = ShowingDetail.State(movie: movie)
            $0.showingDetail?.selectedDate = Calendar.current.startOfDay(for: showing.date)
        }

        await store.send(.showingDetail(.exitButtonDidTap)) {
            $0.isNavigationToShowingDetailActive = false
        }
    }

    func testSettingNavigationToMovieDetail() async {
        let showing = Showing()
        let movie = Movie(showings: [showing])

        let store = TestStore(
            initialState: MovieDetail.State(movie: movie),
            reducer: MovieDetail()
        )

        await store.send(.setNavigationToShowingDetail(isActive: true)) {
            $0.isNavigationToShowingDetailActive = true
            $0.showingDetail = ShowingDetail.State(movie: movie)
            $0.showingDetail?.selectedDate = Calendar.current.startOfDay(for: showing.date)
        }

        await store.send(.setNavigationToShowingDetail(isActive: false)) {
            $0.isNavigationToShowingDetailActive = false
        }
    }

    func testUpdatingTitleViewOverlapPercentage() async {
        let store = TestStore(
            initialState: MovieDetail.State(movie: Movie()),
            reducer: MovieDetail()
        )

        await store.send(.updateTitleViewOverlap(percentage: 0.67)) {
            $0.titleViewOverlapPercentage = 0.67
        }
    }
}
