//
//  MovieFetcherTests.swift
//  CinemaTests
//
//  Created by Marius on 2020-11-15.
//  Copyright © 2020 Marius. All rights reserved.
//

import XCTest
@testable import iKinas

final class MovieFetcherTests: XCTestCase {
    var sut: MovieFetcher!

    override func setUp() {
        sut = MovieFetcher()
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
        let showing = Showing.create(city, date, venue, is3D, url)

        let title = "testTitle"
        let originalTitle = "testOriginalTitle"
        let year = "testYear"
        let ageRating = "testAgeRating"
        let duration = "testDuration"
        let genres = ["test", "genres"]
        let plot = "testPlot"
        let poster = URL(string: "https://test.url")!
        let movie = Movie.create(title, originalTitle, year, ageRating, duration, genres, plot, poster, [showing])

        let session = URLSession.makeMockSession(with: [movie].encoded())

        sut.fetch(using: session) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Fetching should succeed!")
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
    }

    func testFetchingFailureWhenDataCouldNotBeDecoded() {
        let session = URLSession.makeMockSession(with: Data())

        sut.fetch(using: session) { result in
            switch result {
            case .success:
                XCTFail("Fetching should fail!")
            case .failure(let error):
                print(error.localizedDescription)
                XCTAssertNotNil(error as? DecodingError)
            }
        }
    }

    func testFetchingFailureWhenNotConnectedToInternet() {
        let session = URLSession.makeMockSession(with: nil)

        sut.fetch(using: session) { result in
            switch result {
            case .success:
                XCTFail("Fetching should fail!")
            case .failure(let error):
                let error = error as? URLError
                XCTAssertEqual(error?.errorCode, URLError.notConnectedToInternet.rawValue)
            }
        }
    }

    func testGettingShowings() {
        let today = Date.today
        let tommorow = Date.tommorow

        let showings = [
            Showing.create(.vilnius, today, .multikino, true, URL(string: "some.url")!),
            Showing.create(.vilnius, today, .multikino, true, URL(string: "some.url")!),
            Showing.create(.vilnius, today, .multikino, true, URL(string: "some.url")!),
            Showing.create(.vilnius, tommorow, .multikino, true, URL(string: "some.url")!),
            Showing.create(.vilnius, tommorow, .multikino, true, URL(string: "some.url")!)
        ]

        let movie = Movie.create("", "", "", "", "", [], "", URL(string: "some.url")!, showings)

        let session = URLSession.makeMockSession(with: [movie].encoded())

        sut.fetch(using: session) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Fetching should succeed!")
            }

            let todayShowings = self.sut.getShowings(at: today)
            let tommorowShowings = self.sut.getShowings(at: tommorow)

            XCTAssertEqual(todayShowings.count, 3)
            XCTAssertEqual(tommorowShowings.count, 2)
        }
    }

    func testGettingMovies() {
        let today = Date.today
        let tommorow = Date.tommorow
        let title = "testTitle"

        let showings0 = [
            Showing.create(.vilnius, today, .multikino, true, URL(string: "some.url")!),
            Showing.create(.vilnius, today, .multikino, true, URL(string: "some.url")!),
            Showing.create(.vilnius, today, .multikino, true, URL(string: "some.url")!),
            Showing.create(.vilnius, tommorow, .multikino, true, URL(string: "some.url")!),
            Showing.create(.vilnius, tommorow, .multikino, true, URL(string: "some.url")!)
        ]
        
        let showings1 = [
            Showing.create(.vilnius, tommorow, .multikino, true, URL(string: "some.url")!),
            Showing.create(.vilnius, tommorow, .multikino, true, URL(string: "some.url")!)
        ]

        let movies = [
            Movie.create(title, "", "", "", "", [], "", URL(string: "some.url")!, showings0),
            Movie.create("", "", "", "", "", [], "", URL(string: "some.url")!, showings1)
        ]

        let session = URLSession.makeMockSession(with: movies.encoded())

        sut.fetch(using: session) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Fetching should succeed!")
            }

            let todayMovies = self.sut.getMovies(at: today)

            XCTAssertEqual(todayMovies.count, 1)
            XCTAssertEqual(todayMovies[0].title, title)
        }
    }
}
