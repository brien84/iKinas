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
        app.settingsSelectCity(0)
        waitForUIUpdate()
    }

    override func tearDown() {
        app = nil
    }

    func waitForUIUpdate() {
        let expectation = self.expectation(description: "Wait for UI to update.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.6)
    }

    func testAppStartingWithDateViewController() {
        XCTAssertTrue(app.dateContainerVCCollectionView.exists)
        XCTAssertTrue(app.dateVCTableView.exists)
    }

    func testChangingDate() {
        let collectionInitialCount = app.dateContainerVCCollectionView.cellCount
        let tableInitialCount = app.dateVCTableView.cellCount

        app.dateVCRightNavButton.tap()
        waitForUIUpdate()

        var collectionNewCount = app.dateContainerVCCollectionView.cellCount
        var tableNewCount = app.dateVCTableView.cellCount

        XCTAssertNotEqual(collectionInitialCount, collectionNewCount)
        XCTAssertNotEqual(tableInitialCount, tableNewCount)

        app.dateVCLeftNavButton.tap()
        waitForUIUpdate()

        collectionNewCount = app.dateContainerVCCollectionView.cellCount
        tableNewCount = app.dateVCTableView.cellCount

        XCTAssertEqual(collectionInitialCount, collectionNewCount)
        XCTAssertEqual(tableInitialCount, tableNewCount)
    }

    func testNavigationToSettings() {
        app.dateVCLeftNavButton.tap()
        waitForUIUpdate()

        XCTAssertTrue(app.settingsVCTableView.exists)
        XCTAssertFalse(app.dateContainerVCCollectionView.exists)
        XCTAssertFalse(app.dateVCTableView.exists)
    }

    func testNavigationToMovieVCFromDateCollectionView() {
        app.dateContainerVCCollectionView.selectCell(0)
        waitForUIUpdate()

        XCTAssertTrue(app.movieVCView.exists)
        XCTAssertFalse(app.movieVCShowingView.exists)
    }

    func testNavigationToMovieVCFromDateTableView() {
        app.dateVCTableView.selectCell(0)
        waitForUIUpdate()

        XCTAssertTrue(app.movieVCView.exists)
        XCTAssertTrue(app.movieVCShowingView.exists)
    }

    func testNavigationToWebVCFromMovieView() {
        app.dateVCTableView.selectCell(0)
        waitForUIUpdate()

        XCTAssertTrue(app.movieVCView.exists)
        XCTAssertTrue(app.movieVCShowingView.exists)

        app.movieVCShowingButton.tap()
        waitForUIUpdate()

        XCTAssertTrue(app.webVCView.exists)
    }

    func testNavigationToShowingsVCFromMovieView() {
        app.dateContainerVCCollectionView.selectCell(0)
        waitForUIUpdate()

        XCTAssertTrue(app.movieVCView.exists)

        app.movieVCShowingsButton.tap()
        waitForUIUpdate()

        XCTAssertTrue(app.showingsVCView.exists)
    }

    func testNavigationToWebVCFromShowingsTimesView() {
        app.dateContainerVCCollectionView.selectCell(0)
        waitForUIUpdate()

        XCTAssertTrue(app.movieVCView.exists)

        app.movieVCShowingsButton.tap()
        waitForUIUpdate()

        XCTAssertTrue(app.showingsVCView.exists)

        app.showingsVCTimesView.selectCell(0)
        waitForUIUpdate()

        XCTAssertTrue(app.webVCView.exists)
    }

    func testNavigatingDatesViewUpdatesTimesView() {
        app.dateContainerVCCollectionView.selectCell(0)
        waitForUIUpdate()

        XCTAssertTrue(app.movieVCView.exists)

        app.movieVCShowingsButton.tap()
        waitForUIUpdate()

        XCTAssertTrue(app.showingsVCView.exists)

        let initialCount = app.showingsVCDatesView.cellCount

        app.showingsVCDatesView.swipeLeft()
        waitForUIUpdate()

        let newCount = app.showingsVCDatesView.cellCount

        XCTAssertNotEqual(initialCount, newCount)
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

    func settingsSelectCity(_ index: Int) {
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
