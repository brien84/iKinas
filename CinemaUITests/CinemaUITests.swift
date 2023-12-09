//
//  CinemaUITests.swift
//  CinemaUITests
//
//  Created by Marius on 2020-02-23.
//  Copyright © 2020 Marius. All rights reserved.
//

import XCTest

final class CinemaUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
    }

    override func tearDown() {
        app = nil
    }

    func testUI() throws {
        closeSettings()
        openSettings()
        toggleSettings()
        closeSettings()

        openShowingInfoView()
        toggleShowingTimesView()
        selectSimilarMovie()
        closeShowingInfoView()

        selectUpcomingShowing()
        selectFeaturedShowing()
        tapHomeFeedScheduleButton()
        tapHomeFeedButton()

        toggleDateSelector()
        toggleTimeFiltering()
        selectMovieListViewItem()
        selectShowingListViewItem()
    }

    func closeSettings() {
        let element = app.buttons["Close"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func openSettings() {
        let element = app.buttons["gearshape"]
        XCTAssertTrue(element.waitForExistence(timeout: 3.0))
        element.tap()
    }

    func toggleSettings() {
        let initialCount = app.buttons.count

        var element = app.buttons["Kaunas"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        XCTAssertNotEqual(initialCount, app.buttons.count)

        element = app.buttons["Vilnius"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        XCTAssertEqual(initialCount, app.buttons.count)
    }

    func openShowingInfoView() {
        let element = app.otherElements["UpcomingListView"].staticTexts["Movie 1"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func closeShowingInfoView() {
        let element = app.buttons["Back"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func selectSimilarMovie() {
        var element = app.otherElements["SimilarMoviesList"].images.firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        element = app.buttons["Back"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func toggleShowingTimesView() {
        var element = app.buttons["trailers"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        element = app.buttons["Close"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func tapHomeFeedButton() {
        let element = app.buttons["Home"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func tapHomeFeedScheduleButton() {
        let element = app.buttons["Artimiausi"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func selectUpcomingShowing() {
        var element = app.otherElements["UpcomingListView"].staticTexts["Movie 1"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        element = app.buttons["Back"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func selectFeaturedShowing() {
        var element = app.otherElements["FeaturedListView"].staticTexts["Movie 1"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        element = app.buttons["Back"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func toggleDateSelector() {
        var element = app.staticTexts["ŠND"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
        XCTAssertTrue(app.staticTexts["Šiandien"].waitForExistence(timeout: 1.0))

        element = app.staticTexts["RYT"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
        XCTAssertTrue(app.staticTexts["Rytoj"].waitForExistence(timeout: 1.0))
    }

    func toggleTimeFiltering() {
        XCTAssertEqual(app.datePickers.count, 0)

        let element = app.buttons["Stopwatch"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        XCTAssertGreaterThan(app.datePickers.count, 0)
    }

    func selectMovieListViewItem() {
        var element = app.otherElements["MovieListView"].images.firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        element = app.buttons["Back"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func selectShowingListViewItem() {
        var element = app.otherElements["ShowingListView"].images.firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        element = app.buttons["Back"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }
}
