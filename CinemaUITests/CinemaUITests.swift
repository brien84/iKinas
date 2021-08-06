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

        // Selects city on app startup.
        app.settingsVCSelectCity(0)
        XCTAssertTrue(app.dateContainerVCCollectionView.waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.dateVCTableView.waitForExistence(timeout: 2.0))
    }

    override func tearDown() {
        app = nil
    }

    func testChangingDateContainerVCDate() {
        let collectionInitialCount = app.dateContainerVCCollectionView.cellCount
        let tableInitialCount = app.dateVCTableView.cellCount

        app.dateVCRightNavButton.tap()

        var collectionNewCount = app.dateContainerVCCollectionView.cellCount
        var tableNewCount = app.dateVCTableView.cellCount

        XCTAssertNotEqual(collectionInitialCount, collectionNewCount)
        XCTAssertNotEqual(tableInitialCount, tableNewCount)

        app.dateVCLeftNavButton.tap()

        collectionNewCount = app.dateContainerVCCollectionView.cellCount
        tableNewCount = app.dateVCTableView.cellCount

        XCTAssertEqual(collectionInitialCount, collectionNewCount)
        XCTAssertEqual(tableInitialCount, tableNewCount)
    }

    func testNavigatingToSettingsVC() {
        app.dateVCLeftNavButton.tap()

        XCTAssertTrue(app.settingsVCTableView.waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.dateContainerVCCollectionView.exists)
        XCTAssertFalse(app.dateVCTableView.exists)
    }

    func testNavigatingToMovieVCFromDateCollectionView() {
        app.dateContainerVCCollectionView.selectCell(0)

        XCTAssertTrue(app.movieVCView.waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.movieVCShowingView.exists)
    }

    func testNavigatingToMovieVCFromDateTableView() {
        app.dateVCTableView.selectCell(0)

        XCTAssertTrue(app.movieVCView.waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.movieVCShowingView.waitForExistence(timeout: 2.0))
    }

    func testNavigatingToWebVCFromMovieView() {
        testNavigatingToMovieVCFromDateTableView()

        app.movieVCShowingButton.tap()

        XCTAssertTrue(app.webVCView.waitForExistence(timeout: 2.0))
    }

    func testNavigatingToShowingsVCFromMovieView() {
        app.dateContainerVCCollectionView.selectCell(0)

        XCTAssertTrue(app.movieVCView.waitForExistence(timeout: 2.0))

        app.movieVCShowingsButton.tap()

        XCTAssertTrue(app.showingsVCView.waitForExistence(timeout: 2.0))
    }

    func testChangingDateInDatesViewUpdatesTimesView() {
        testNavigatingToShowingsVCFromMovieView()

        let initialCount = app.showingsVCDatesView.cellCount
        app.showingsVCDatesView.swipeLeft()
        let newCount = app.showingsVCDatesView.cellCount

        XCTAssertNotEqual(initialCount, newCount)
    }

    func testNavigatingToWebVCFromShowingsTimesView() {
        testNavigatingToShowingsVCFromMovieView()

        app.showingsVCTimesView.selectCell(0)

        XCTAssertTrue(app.webVCView.waitForExistence(timeout: 2.0))
    }
}

extension XCUIApplication {

    // MARK: DateContainerViewController

    var dateContainerVCCollectionView: XCUIElement {
        collectionViews["dateContainerVCCollectionView"]
    }

    // MARK: DateViewController

    var dateVCTableView: XCUIElement {
        tables["dateVCTableView"]
    }

    var dateVCLeftNavButton: XCUIElement {
        buttons["dateVCLeftNavButton"]
    }

    var dateVCRightNavButton: XCUIElement {
        buttons["dateVCRightNavButton"]
    }

    // MARK: MovieViewController

    var movieVCView: XCUIElement {
        otherElements["movieVCView"]
    }

    var movieVCShowingView: XCUIElement {
        otherElements["movieVCShowingView"]
    }

    var movieVCShowingButton: XCUIElement {
        buttons["movieVCShowingButton"]
    }

    var movieVCShowingsButton: XCUIElement {
        buttons["movieVCShowingsButton"]
    }

    // MARK: SettingsViewController

    var settingsVCTableView: XCUIElement {
        tables["settingsVCTableView"]
    }

    func settingsVCSelectCity(_ index: Int) {
        settingsVCTableView.selectCell(index)
    }

    // MARK: ShowingsViewController

    var showingsVCView: XCUIElement {
        otherElements["showingsVCView"]
    }

    var showingsVCDatesView: XCUIElement {
        collectionViews["showingsVCDatesView"]
    }

    var showingsVCContainersView: XCUIElement {
        collectionViews["showingsVCContainersView"]
    }

    var showingsVCTimesView: XCUIElement {
        collectionViews["showingsVCTimesView"]
    }

    // MARK: WebViewController

    var webVCView: XCUIElement {
        webViews["webVCView"]
    }
}

extension XCUIElement {
    func selectCell(_ index: Int) {
        self.cells.element(boundBy: index).tap()
    }

    var cellCount: Int {
        return self.cells.count
    }
}
