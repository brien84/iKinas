//
//  ShowingTests.swift
//  CinemaTests
//
//  Created by Marius on 2023-12-06.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class ShowingTests: XCTestCase {

    func testFilteringByDate() async {
        let showings = stride(from: 0, through: 10, by: 0.5).map { index in
            Previews.createShowing(date: Date(timeIntervalSinceNow: .fullDay * index))
        }.convertToIdentifiedArray()

        let filtered = showings.filter(by: Date(timeIntervalSinceNow: .fullDay))

        XCTAssertEqual(filtered.count, 2)
    }

    func testFilteringByTitle() async {
        let showings = [
            Previews.createShowing(title: "filterTitle"),
            Previews.createShowing(title: "filterTitle"),
            Previews.createShowing(title: "filterTitle"),
            Previews.createShowing(title: "someOtherTitle"),
            Previews.createShowing(title: "someOtherTitle")
        ].convertToIdentifiedArray()

        let filtered = showings.filter(by: "filterTitle")

        XCTAssertEqual(filtered.count, 3)
    }

    func testFilteringFromStartDateToEndDate() async {
        let referenceDate = Date()
        let showings = stride(from: 0, through: 10, by: 1).map { index in
            Previews.createShowing(date: Date(timeInterval: .hour * index, since: referenceDate))
        }.convertToIdentifiedArray()

        let filtered = showings.filter(
            from: Date(timeInterval: .hour * 3, since: referenceDate),
            to: Date(timeInterval: .hour * 6, since: referenceDate)
        )

        XCTAssertEqual(filtered.count, 4)
    }

    func testFilteringSimilarShowings() async {
        let showing = Previews.createShowing(genres: ["A", "B"], metadata: ["C"], title: UUID().uuidString)
        let showings = [
            Previews.createShowing(genres: ["A", "B"], metadata: [], title: UUID().uuidString),
            Previews.createShowing(genres: ["A"], metadata: ["C"], title: UUID().uuidString),
            Previews.createShowing(genres: ["A"], metadata: [], title: UUID().uuidString),
            Previews.createShowing(genres: [], metadata: ["C"], title: UUID().uuidString),
            Previews.createShowing(genres: ["D"], metadata: ["F"], title: UUID().uuidString)
        ].convertToIdentifiedArray()

        let filtered = showings.filter(similarTo: showing)

        XCTAssertEqual(filtered.count, 2)
    }

    func testFilteringSimilarSingleGenreShowings() async {
        let showing = Previews.createShowing(genres: ["A"], title: UUID().uuidString)
        let showings = [
            Previews.createShowing(genres: ["A", "B"], title: UUID().uuidString),
            Previews.createShowing(genres: ["A"], title: UUID().uuidString),
            Previews.createShowing(genres: [], title: UUID().uuidString),
            Previews.createShowing(genres: ["D"], title: UUID().uuidString)
        ].convertToIdentifiedArray()

        let filtered = showings.filter(similarTo: showing)

        XCTAssertEqual(filtered.count, 2)
    }

    func testFilteringFirstOccurencesOfTitles() async {
        let showings = [
            Previews.createShowing(title: "A"),
            Previews.createShowing(title: "A"),
            Previews.createShowing(title: "A"),
            Previews.createShowing(title: "B"),
            Previews.createShowing(title: "B"),
            Previews.createShowing(title: "C"),
            Previews.createShowing(title: "C")
        ].convertToIdentifiedArray()

        var filtered = showings.filterFirstOccurrencesOf(titles: ["B", "C"])
        filtered.sort(by: .title)

        XCTAssertEqual(filtered, [showings[3], showings[5]])
    }

    func testFilteringFutureShowings() async {
        let showings = [
            Previews.createShowing(date: Date(timeInterval: -100000, since: Date())),
            Previews.createShowing(date: Date(timeInterval: -100000, since: Date())),
            Previews.createShowing(date: Date(timeInterval: -100000, since: Date())),
            Previews.createShowing(date: Date(timeInterval: 100000, since: Date())),
            Previews.createShowing(date: Date(timeInterval: 100000, since: Date()))
        ].convertToIdentifiedArray()

        let filtered = showings.filterFutureShowings()

        XCTAssertEqual(filtered.count, 2)
    }

    func testGettingUniqueTitles() async {
        let showings = [
            Previews.createShowing(title: "A"),
            Previews.createShowing(title: "A"),
            Previews.createShowing(title: "A"),
            Previews.createShowing(title: "B"),
            Previews.createShowing(title: "C"),
            Previews.createShowing(title: "C")
        ].convertToIdentifiedArray()

        let titles = showings.getUniqueTitles()

        XCTAssertEqual(titles, ["A", "B", "C"])
    }

    func testGettingUpcomingDays() async {
        let referenceDate = Date()
        let showings = stride(from: 0, through: 10, by: 1).map { index in
            Previews.createShowing(date: Date(timeInterval: .fullDay * index, since: referenceDate))
        }.convertToIdentifiedArray()

        let days = showings.getUpcomingDays()

        XCTAssertEqual(
            days,
            stride(from: 0, through: 10, by: 1).map {
                let date = Date(timeInterval: .fullDay * $0, since: referenceDate)
                return Calendar.current.startOfDay(for: date)
            }
        )
    }

    func testSortingByDate() async {
        let referenceDate = Date()
        var showings = [
            Previews.createShowing(date: Date(timeInterval: 1, since: referenceDate)),
            Previews.createShowing(date: Date(timeInterval: 3, since: referenceDate)),
            Previews.createShowing(date: Date(timeInterval: 4, since: referenceDate)),
            Previews.createShowing(date: Date(timeInterval: 2, since: referenceDate)),
            Previews.createShowing(date: Date(timeInterval: 0, since: referenceDate))
        ].convertToIdentifiedArray()

        showings.sort(by: .date)

        XCTAssertEqual(
            showings.map { $0.date.timeIntervalSince(referenceDate) },
            [0, 1, 2, 3, 4]
        )
    }

    func testSortingByTitle() async {
        var showings = [
            Previews.createShowing(title: "E"),
            Previews.createShowing(title: "C"),
            Previews.createShowing(title: "D"),
            Previews.createShowing(title: "A"),
            Previews.createShowing(title: "B")
        ].convertToIdentifiedArray()

        showings.sort(by: .title)

        XCTAssertEqual(showings.map { $0.title }, ["A", "B", "C", "D", "E"])
    }

}
