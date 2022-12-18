//
//  MovieListTests.swift
//  CinemaTests
//
//  Created by Marius on 2022-12-18.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class MovieListTests: XCTestCase {

    func testUpdateMovieItems() async {
        let store = TestStore(
            initialState: MovieList.State(),
            reducer: MovieList()
        )

        let uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        store.dependencies.uuid = .constant(uuid)

        let movie = Movie()

        await store.send(.update(movies: [movie])) {
            $0.movieItems = [MovieItem.State(id: uuid, movie: movie)]
        }
    }

}
