//
//  DateTrackerTests.swift
//  CinemaTests
//
//  Created by Marius on 15/11/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import XCTest
@testable import iKinas

final class DateTrackerTests: XCTestCase {
    var sut: DateTracker!

    override func setUp() {
        sut = DateTracker()
    }

    override func tearDown() {
        sut = nil
    }

    func testInitGeneratesFutureDates() {
        XCTAssertGreaterThan(DateTracker.dates.count, 0)
    }

    func testNextDate() {
        // given
        let currentDate = sut.selected

        // when
        sut.next()

        // then
        XCTAssertLessThan(currentDate, sut.selected)
    }

    func testNextDateDoesNotGoOutOfRange() {
        // given
        var index = 0

        // then
        while index < 50 {
            sut.next()
            _ = sut.selected
            index += 1
        }
    }

    func testNextDatePostsNotification() {
        // given
        expectation(forNotification: .dateDidChange, object: nil, handler: nil)

        // when
        sut.next()

        // then
        waitForExpectations(timeout: 3)
    }

    func testPreviousDate() {
        // given
        sut.next()
        let currentDate = sut.selected

        // when
        sut.previous()

        // then
        XCTAssertGreaterThan(currentDate, sut.selected)
    }

    func testPreviousDateDoesNotGoOutOfRange() {
        // given
        var index = 0

        // then
        while index < 50 {
            sut.previous()
            _ = sut.selected
            index += 1
        }
    }

    func testPreviousDatePostsNotification() {
        // given
        sut.next()
        expectation(forNotification: .dateDidChange, object: nil, handler: nil)

        // when
        sut.previous()

        // then
        waitForExpectations(timeout: 3)
    }
}
