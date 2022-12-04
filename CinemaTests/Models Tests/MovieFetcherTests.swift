//
//  MovieFetcherTests.swift
//  CinemaTests
//
//  Created by Marius on 2020-11-15.
//  Copyright © 2020 Marius. All rights reserved.
//

import XCTest
@testable import iKinas

// swiftlint:disable function_body_length
final class MovieFetcherTests: XCTestCase {
    var sut: MovieFetcher!
    var userDefaults: UserDefaults!

    override func setUp() {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)

        sut = MovieFetcher(userDefaults: userDefaults)
    }

    override func tearDown() {
        sut = nil
    }

    func testSuccessfulFetching() {
        let city = City.vilnius
        let date = Date.today
        let venue = Venue.multikino
        let is3D = true
        let url = URL(string: "https://google.com")!
        let showing = Showing.create(city: city, date: date, venue: venue, is3D: is3D, url: url)

        let title = "testTitle"
        let originalTitle = "testOriginalTitle"
        let year = "testYear"
        let ageRating = "testAgeRating"
        let duration = "testDuration"
        let genres = ["test", "genres"]
        let plot = "testPlot"
        let poster = URL(string: "https://test.url")!

        let movie = Movie.create(
                        title: title,
                        originalTitle: originalTitle,
                        year: year,
                        ageRating: ageRating,
                        duration: duration,
                        genres: genres,
                        plot: plot,
                        poster: poster,
                        showings: [showing]
                    )

        let session = URLSession.makeMockSession(with: [movie].encoded())

        let expectation = expectation(description: "Waiting for fetching to complete.")
        var result: Result<Void, Error>?

        sut.fetch(using: session) {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Fetching should succeed!")
        case .none:
            XCTFail("Result should have a value!")
        }

        let movies = self.sut.getMovies(at: date)

        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual(movies[0].title, title)
        XCTAssertEqual(movies[0].originalTitle, originalTitle)
        XCTAssertEqual(movies[0].year, year)
        XCTAssertEqual(movies[0].ageRating, ageRating)
        XCTAssertEqual(movies[0].duration, duration)
        XCTAssertEqual(movies[0].genres, genres)
        XCTAssertEqual(movies[0].plot, plot)
        XCTAssertEqual(movies[0].poster, poster)

        XCTAssertEqual(movies[0].showings.count, 1)
        XCTAssertEqual(movies[0].showings[0].city, city)
        XCTAssertEqual(movies[0].showings[0].date, date)
        XCTAssertEqual(movies[0].showings[0].venue, venue)
        XCTAssertEqual(movies[0].showings[0].is3D, is3D)
        XCTAssertEqual(movies[0].showings[0].url, url)
        XCTAssertEqual(movies[0].showings[0].parentMovie, movies[0])
    }

    func testFetchingFailureWhenDataCouldNotBeDecoded() {
        let session = URLSession.makeMockSession(with: Data())

        let expectation = expectation(description: "Waiting for fetching to complete.")
        var result: Result<Void, Error>?

        sut.fetch(using: session) {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        switch result {
        case .success:
            XCTFail("Fetching should fail!")
        case .failure(let error):
            print(error.localizedDescription)
            XCTAssertNotNil(error as? DecodingError)
        case .none:
            XCTFail("Result should have a value!")
        }
    }

    func testFetchingFailureWhenNotConnectedToInternet() {
        let session = URLSession.makeMockSession(with: nil)

        let expectation = expectation(description: "Waiting for fetching to complete.")
        var result: Result<Void, Error>?

        sut.fetch(using: session) {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        switch result {
        case .success:
            XCTFail("Fetching should fail!")
        case .failure(let error):
            let error = error as? URLError
            XCTAssertEqual(error?.errorCode, URLError.notConnectedToInternet.rawValue)
        case .none:
            XCTFail("Result should have a value!")
        }
    }

    func testGettingShowings() {
        let today = Date.today
        let tommorow = Date.tommorow

        let showings = [
            Showing.create(date: today, venue: .multikino),
            Showing.create(date: today, venue: .multikino),
            Showing.create(date: today, venue: .multikino),
            Showing.create(date: tommorow, venue: .multikino),
            Showing.create(date: tommorow, venue: .multikino)
        ]

        let movie = Movie.create(showings: showings)

        let session = URLSession.makeMockSession(with: [movie].encoded())

        let expectation = expectation(description: "Waiting for fetching to complete.")
        var result: Result<Void, Error>?

        sut.fetch(using: session) {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Fetching should succeed!")
        case .none:
            XCTFail("Result should have a value!")
        }

        let todayShowings = sut.getShowings(at: today)
        let tommorowShowings = sut.getShowings(at: tommorow)

        XCTAssertEqual(todayShowings.count, 3)
        XCTAssertEqual(tommorowShowings.count, 2)
    }

    func testGettingMovies() {
        let today = Date.today
        let tommorow = Date.tommorow
        let title = "testTitle"

        let showings0 = [
            Showing.create(date: today),
            Showing.create(date: today),
            Showing.create(date: today),
            Showing.create(date: tommorow),
            Showing.create(date: tommorow)
        ]

        let showings1 = [
            Showing.create(date: tommorow),
            Showing.create(date: tommorow)
        ]

        let movies = [
            Movie.create(title: title, showings: showings0),
            Movie.create(showings: showings1)
        ]

        let session = URLSession.makeMockSession(with: movies.encoded())

        let expectation = expectation(description: "Waiting for fetching to complete.")
        var result: Result<Void, Error>?

        sut.fetch(using: session) {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Fetching should succeed!")
        case .none:
            XCTFail("Result should have a value!")
        }

        let todayMovies = self.sut.getMovies(at: today)

        XCTAssertEqual(todayMovies.count, 1)
        XCTAssertEqual(todayMovies[0].title, title)
    }
}
