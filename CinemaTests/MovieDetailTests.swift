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

    func testSettingWebViewURL() async {
        let showing = Showing()
        let movie = Movie(showings: [showing])

        let store = TestStore(
            initialState: MovieDetail.State(movie: movie),
            reducer: MovieDetail()
        )

        await store.send(.setWebView(url: showing.url)) {
            $0.webViewURL = showing.url
        }
    }

}
