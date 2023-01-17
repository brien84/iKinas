//
//  CinemaUITests.swift
//  CinemaUITests
//
//  Created by Marius on 2020-02-23.
//  Copyright © 2020 Marius. All rights reserved.
//

import XCTest

enum LaunchArgument: String {
    case common = "ui-testing"
    case firstLaunch = "ui-testing-first-launch"
}

final class CinemaUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false

        app = XCUIApplication()
    }

    override func tearDown() {
        app = nil
    }

    func testSettingsViewAppearsOnFirstLaunch() {
        app.launchArguments = [LaunchArgument.firstLaunch.rawValue]
        app.launch()

        XCTAssertTrue(app.staticTexts["Pasirinkite teatrus"].waitForExistence(timeout: 5.0))
    }

    func testChangingDates() {
        app.launchArguments = [LaunchArgument.common.rawValue]
        app.launch()

        let dateSelector = app.scrollViews.element(boundBy: 0)

        var showings = app.staticTexts.allElementsBoundByIndex.filter { $0.label.contains("Movie Title") }
        XCTAssertEqual(showings.count, 2)
        dateSelector.buttons.element(boundBy: 0).tap()
        showings = app.staticTexts.allElementsBoundByIndex.filter { $0.label.contains("Movie Title") }
        XCTAssertEqual(showings.count, 1)

        dateSelector.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts.allElementsBoundByIndex.contains(where: { $0.label == "nieko nerodo" }))
    }

    func testNavigationToSettingsView() {
        app.launchArguments = [LaunchArgument.common.rawValue]
        app.launch()

        // opens SettingsView
        app.buttons["gearshape"].tap()
        XCTAssertTrue(app.staticTexts["Pasirinkite teatrus"].waitForExistence(timeout: 5.0))

        // selects different city
        var venueButtons = app.buttons.allElementsBoundByIndex.filter { $0.label.contains("Selected") }
        XCTAssertEqual(venueButtons.count, 3)
        app.buttons["Šiauliai"].tap()
        venueButtons = app.buttons.allElementsBoundByIndex.filter { $0.label.contains("Selected") }
        XCTAssertEqual(venueButtons.count, 2)

        // validates that last selected button gets disabled
        XCTAssertFalse(venueButtons.contains(where: { !$0.isEnabled }))
        venueButtons.first?.tap()
        XCTAssertTrue(venueButtons.contains(where: { !$0.isEnabled }))

        // closes SettingsView
        app.buttons["Close"].tap()
        XCTAssertTrue(app.buttons["gearshape"].waitForExistence(timeout: 5.0))
    }

    func testOpeningSafariViewFromMovieDetailView() {
        app.launchArguments = [LaunchArgument.common.rawValue]
        app.launch()

        // opens MovieDetailView
        app.staticTexts["Movie Title"].firstMatch.tap()
        XCTAssertTrue(app.buttons["Shopping Cart"].waitForExistence(timeout: 5.0))

        // opens SafariView
        app.buttons["Shopping Cart"].tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5.0))

        // closes SafariView
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Shopping Cart"].waitForExistence(timeout: 5.0))
    }

    func testOpeningSafariViewFromShowingDetailView() {
        app.launchArguments = [LaunchArgument.common.rawValue]
        app.launch()

        // opens MovieDetailView
        app.staticTexts["Movie Title"].firstMatch.tap()
        XCTAssertTrue(app.buttons["trailers"].waitForExistence(timeout: 5.0))

        // opens to ShowingDetailView
        app.buttons["trailers"].tap()
        XCTAssertTrue(app.staticTexts["Seansai"].waitForExistence(timeout: 5.0))

        // opens SafariView by tapping on any showing
        app.collectionViews.firstMatch.descendants(matching: .staticText).firstMatch.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5.0))

        // closes SafariView
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["trailers"].waitForExistence(timeout: 5.0))

        // closes MovieDetailView
        app.buttons["Back"].tap()
        XCTAssertTrue(app.buttons["Home"].waitForExistence(timeout: 5.0))
    }
}
