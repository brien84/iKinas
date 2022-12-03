//
//  SettingsViewControllerTests.swift
//  CinemaTests
//
//  Created by Marius on 15/11/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import XCTest
@testable import iKinas

final class SettingsViewControllerTests: XCTestCase {
    var sut: SettingsViewController!

    override func setUp() {
        setupSUT()
    }

    override func tearDown() {
        sut = nil
    }

    func testTableViewHasCorrectNumberOfRows() {
        sut.loadViewIfNeeded()

        let rowCount = sut.tableView(sut.tableView, numberOfRowsInSection: 0)

        XCTAssertEqual(rowCount, City.allCases.count)
    }

    func testTableViewCellsHaveCorrectValuesSet() {
        sut.loadViewIfNeeded()

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? SettingsViewCell

        XCTAssertEqual(cell?.city.text, City.allCases[0].rawValue)
    }

    func testTableViewContentInsetAdjustmentBehaviorIsNever() {
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.tableView.contentInsetAdjustmentBehavior, .never)
    }

    func testTableViewScrollIsDisabled() {
        sut.loadViewIfNeeded()

        XCTAssertFalse(sut.tableView.isScrollEnabled)
    }

    func testTableViewHeaderIsNotNil() {
        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.tableView.tableHeaderView)
    }

    func testSelectingRowSendsNotification() {
        expectation(forNotification: .SettingsDidChange, object: nil, handler: nil)

        sut.tableView(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

        waitForExpectations(timeout: 3)
    }

    func testNavigationBarIsHidden() {
        _ = UINavigationController(rootViewController: sut)

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.navigationController?.isNavigationBarHidden ?? false)
    }

    // MARK: Test Helpers

    func setupSUT() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "settingsVC") as? SettingsViewController
    }
}
