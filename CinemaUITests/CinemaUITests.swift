//
//  CinemaUITests.swift
//  CinemaUITests
//
//  Created by Marius on 2020-02-23.
//  Copyright © 2020 Marius. All rights reserved.
//

import XCTest

// swiftlint:disable identifier_name
final class CinemaUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()

        // UI Tests start with `SettingsView` as if
        // user launched the app for the first time.
        closeSettingsView()
    }

    override func tearDown() {
        app = nil
    }

    func debugElementIdentifiers() {
        let allElements = app.descendants(matching: .any)
        var allHittableElements = [XCUIElement]()
        for index in 0..<allElements.count {
            let element = allElements.element(boundBy: index)
            if element.isHittable {
                allHittableElements.append(element)
            }
        }

        allHittableElements.forEach {
            print($0)
        }
    }

    func closeSettingsView() {
        XCTAssertTrue(app.SettingsView_ExitButtonView.waitForExistence(timeout: 2.0))

        app.SettingsView_ExitButtonView.tap()

        XCTAssertFalse(app.SettingsView_ExitButtonView.waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.dateContainerVCCollectionView.waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.dateVCTableView.waitForExistence(timeout: 2.0))
    }

    func testSettingsViewChangingCity() {
        app.dateVCLeftNavButton.tap()

        XCTAssertTrue(app.SettingsView_VenueButton_vilnius_apollo.exists)
        XCTAssertTrue(app.SettingsView_VenueButton_vilnius_forum.exists)
        XCTAssertTrue(app.SettingsView_VenueButton_vilnius_multikino.exists)
        XCTAssertFalse(app.SettingsView_VenueButton_kaunas_cinamon.exists)
        XCTAssertFalse(app.SettingsView_VenueButton_kaunas_forum.exists)

        app.SettingsView_CityButton_kaunas.tap()

        XCTAssertTrue(app.SettingsView_VenueButton_kaunas_cinamon.waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.SettingsView_VenueButton_kaunas_forum.waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.SettingsView_VenueButton_vilnius_apollo.exists)
        XCTAssertFalse(app.SettingsView_VenueButton_vilnius_forum.exists)
        XCTAssertFalse(app.SettingsView_VenueButton_vilnius_multikino.exists)
    }

    func testSettingsViewLeavesOneUndisabled() {
        app.dateVCLeftNavButton.tap()

        XCTAssertTrue(app.SettingsView_VenueButton_vilnius_apollo.isEnabled)
        XCTAssertTrue(app.SettingsView_VenueButton_vilnius_forum.isEnabled)
        XCTAssertTrue(app.SettingsView_VenueButton_vilnius_multikino.isEnabled)

        app.SettingsView_VenueButton_vilnius_apollo.tap()
        app.SettingsView_VenueButton_vilnius_forum.tap()

        XCTAssertFalse(app.SettingsView_VenueButton_vilnius_multikino.isEnabled)
    }

    func testSettingsViewHidesCheckmark() {
        app.dateVCLeftNavButton.tap()

        XCTAssertTrue(app.SettingsView_VenueCheckmark_vilnius_apollo.isEnabled)

        app.SettingsView_VenueButton_vilnius_apollo.tap()

        XCTAssertFalse(app.SettingsView_VenueCheckmark_vilnius_apollo.isEnabled)
    }

    func testNavigatingToSettingsView() {
        app.dateVCLeftNavButton.tap()

        XCTAssertTrue(app.SettingsView_ExitButtonView.waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.dateContainerVCCollectionView.exists)
        XCTAssertFalse(app.dateVCTableView.exists)
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

    // MARK: SettingsView

    var SettingsView_ExitButtonView: XCUIElement {
        buttons["SettingsView-ExitButtonView"]
    }

    var SettingsView_CityButton_kaunas: XCUIElement {
        buttons["SettingsView-CityListView-CityButton-kaunas"]
    }

    var SettingsView_VenueButton_vilnius_apollo: XCUIElement {
        buttons["SettingsView-VenueListView-VenueButton-vilnius-apollo"]
    }

    var SettingsView_VenueButton_vilnius_forum: XCUIElement {
        buttons["SettingsView-VenueListView-VenueButton-vilnius-forum"]
    }

    var SettingsView_VenueButton_vilnius_multikino: XCUIElement {
        buttons["SettingsView-VenueListView-VenueButton-vilnius-multikino"]
    }

    var SettingsView_VenueButton_kaunas_cinamon: XCUIElement {
        buttons["SettingsView-VenueListView-VenueButton-kaunas-cinamon"]
    }

    var SettingsView_VenueButton_kaunas_forum: XCUIElement {
        buttons["SettingsView-VenueListView-VenueButton-kaunas-forum"]
    }

    var SettingsView_VenueCheckmark_vilnius_apollo: XCUIElement {
        images["SettingsView-VenueListView-VenueCheckmark-vilnius-apollo"]
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
