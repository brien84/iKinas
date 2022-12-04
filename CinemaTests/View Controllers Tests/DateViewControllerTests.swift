//
//  DateViewControllerTests.swift
//  CinemaTests
//
//  Created by Marius on 2020-12-30.
//  Copyright © 2020 Marius. All rights reserved.
//

import XCTest
@testable import iKinas

final class DateViewControllerTests: XCTestCase {
    var sut: DateViewController!
    var dates: DateTrackerStub!
    var fetcher: MovieFetcherStub!
    var version: VersionVerifierStub!

    override func setUpWithError() throws {
        dates = DateTrackerStub()
        fetcher = MovieFetcherStub()
        version = VersionVerifierStub()
        setupSUT()
    }

    override func tearDownWithError() throws {
        dates = nil
        fetcher = nil
        sut = nil
    }

    func testTableViewDatasourceCount() {
        sutLoadViewIfNeeded()

        waitForUIUpdate()

        XCTAssertGreaterThan(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 0)
    }

    func testTableViewCellsHaveCorrectValuesSet() {
        let testTitle = "testTitle"
        let testOriginalTitle = "testOriginalTitle"
        let testURL = URL(string: "https://google.com")!
        let testVenue = Venue.multikino
        let testTime = Date.today
        let test3D = true
        let movie = Movie.create(title: testTitle, originalTitle: testOriginalTitle, poster: testURL)
        let showing = Showing.create(city: .vilnius, date: testTime, venue: testVenue, is3D: test3D, url: testURL)
        showing.parentMovie = movie
        fetcher.showings = [showing]

        sutLoadViewIfNeeded()

        waitForUIUpdate()

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? DateViewCell

        XCTAssertEqual(cell?.title.text, testTitle)
        XCTAssertEqual(cell?.originalTitle.text, testOriginalTitle)
        XCTAssertEqual(cell?.poster?.url, testURL)
        XCTAssertEqual(cell?.venueImage.image, UIImage.multikino)
        XCTAssertEqual(cell?.time.text, testTime.asString(.timeOfDay))
        XCTAssertEqual(cell?.is3D, test3D)
    }

    func testSettingsNotificationObserver() {
        sutLoadViewIfNeeded()

        waitForUIUpdate()

        XCTAssertGreaterThan(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 0)

        fetcher.showings = []
        NotificationCenter.default.post(name: .SettingsDidChange, object: nil)

        waitForUIUpdate()

        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 0)
    }

    func testDateTrackerNotificationObserver() {
        let testDateToday = Date.today
        let testDateTommorow = Date.tommorow
        dates.selected = testDateToday

        sutLoadViewIfNeeded()

        waitForUIUpdate()

        let titleView = sut.navigationItem.titleView as? UILabel
        XCTAssertEqual(titleView?.text, testDateToday.asString(.monthAndDay))

        dates.selected = testDateTommorow
        NotificationCenter.default.post(name: .DateDidChange, object: nil)

        waitForUIUpdate()

        XCTAssertEqual(titleView?.text, testDateTommorow.asString(.monthAndDay))
    }

    func testNavigationTitleViewIsSet() {
        let testDateToday = Date.today
        dates.selected = testDateToday

        sutLoadViewIfNeeded()

        waitForUIUpdate()

        let titleView = sut.navigationItem.titleView as? UILabel
        XCTAssertEqual(titleView?.text, testDateToday.asString(.monthAndDay))
    }

    func testNavigationIsReenabledAfterSuccessfulFetch() {
        sutLoadViewIfNeeded()

        XCTAssertFalse(sut.tableView.isScrollEnabled)
        XCTAssertFalse(sut.navigationItem.leftBarButtonItem!.isEnabled)
        XCTAssertFalse(sut.navigationItem.rightBarButtonItem!.isEnabled)

        waitForUIUpdate()

        XCTAssertTrue(sut.tableView.isScrollEnabled)
        XCTAssertTrue(sut.navigationItem.leftBarButtonItem!.isEnabled)
        XCTAssertTrue(sut.navigationItem.rightBarButtonItem!.isEnabled)
    }

    func testScrollIsDisabledWhenDatasourceIsEmpty() {
        fetcher.showings = []
        sutLoadViewIfNeeded()

        waitForUIUpdate()

        XCTAssertFalse(sut.tableView.isScrollEnabled)
        XCTAssertTrue(sut.navigationItem.leftBarButtonItem!.isEnabled)
        XCTAssertTrue(sut.navigationItem.rightBarButtonItem!.isEnabled)
    }

    func testNavigationIsDisabledIfFetchingFails() {
        fetcher.isFetchSuccessful = false
        sutLoadViewIfNeeded()

        waitForUIUpdate()

        XCTAssertFalse(sut.tableView.isScrollEnabled)
        XCTAssertFalse(sut.navigationItem.leftBarButtonItem!.isEnabled)
        XCTAssertFalse(sut.navigationItem.rightBarButtonItem!.isEnabled)
    }

    func testRightNavigationButtonDisableWhenLastDateIsSelected() {
        dates.isLast = true
        sutLoadViewIfNeeded()

        waitForUIUpdate()

        XCTAssertTrue(sut.tableView.isScrollEnabled)
        XCTAssertTrue(sut.navigationItem.leftBarButtonItem!.isEnabled)
        XCTAssertFalse(sut.navigationItem.rightBarButtonItem!.isEnabled)
    }

    func testLeftBarButtonImageIsSettingsWhenFirstDateIsSelected() {
        dates.isFirst = true
        sutLoadViewIfNeeded()

        waitForUIUpdate()

        guard let button = sut.navigationItem.leftBarButtonItem else {
            return XCTFail("leftBarButtonItem is nil!")
        }

        XCTAssertEqual(button.image?.imageAsset, UIImage.settings.imageAsset)
    }

    // MARK: Test Helpers

    func setupSUT() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "dateVC") { [self] coder in
            DateViewController(coder: coder, dates: dates, fetcher: fetcher, version: version)
        }
    }

    func sutLoadViewIfNeeded() {
        sut.loadViewIfNeeded()

        // Remove `DateContainerViewController` to prevent `UIViewControllerHierarchyInconsistency` error.
        sut.children.forEach { $0.removeFromParent() }
    }

    func waitForUIUpdate() {
        let expectation = self.expectation(description: "Wait for UI to update.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    class DateTrackerStub: DateTracking {
        var selected: Date = Date()
        var isFirst: Bool = false
        var isLast: Bool = false

        func previous() { }
        func next() { }
    }

    class MovieFetcherStub: MovieFetching {
        var userDefaults: UserDefaults {
            let userDefaults = UserDefaults(suiteName: #file)!
            userDefaults.removePersistentDomain(forName: #file)
            return userDefaults
        }

        var isFetchSuccessful = true
        var movies = [Movie.create()]
        var showings = [Showing.create()]

        func getMovies(at date: Date) -> [Movie] {
            movies
        }

        func getShowings(at date: Date) -> [Showing] {
            showings
        }

        func fetch(using session: URLSession, completion: @escaping (Result<Void, Error>) -> Void) {
            if isFetchSuccessful {
                completion(.success(()))
            } else {
                completion(.failure(TestError.testError))
            }
        }
    }

    class VersionVerifierStub: VersionVerification {
        func verifyVersion(using session: URLSession, completion: @escaping (Result<Void, VersionVerifier.VersionError>) -> Void) {
            completion(.success(()))
        }
    }

    enum TestError: Error {
        case testError
    }
}
