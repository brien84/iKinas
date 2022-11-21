//
//  VersionVerifierTests.swift
//  CinemaTests
//
//  Created by Marius on 2022-11-20.
//  Copyright © 2022 Marius. All rights reserved.
//

import XCTest
@testable import iKinas

// swiftlint:disable force_try
final class VersionVerifierTests: XCTestCase {
    typealias Error = VersionVerifier.VersionError

    var sut: VersionVerifier!

    override func setUp() {
        sut = VersionVerifier()
    }

    override func tearDown() {
        sut = nil
    }

    func testVerifyingLowerThanSystemVersion() {
        let testVersion = 1.0
        let session = URLSession.makeMockSession(with: try! JSONEncoder().encode(testVersion))

        let expectation = expectation(description: "Waiting for completion handler.")
        var result: Result<Void, Error>?

        sut.verifyVersion(using: session) {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        switch result {
        case .success:
            XCTAssert(true)
        case .failure:
            XCTFail("Verification should succeed!")
        case .none:
            XCTFail("Result should have a value!")
        }
    }

    func testVerifyingHigherThanSystemVersion() {
        let testVersion = 999.0
        let session = URLSession.makeMockSession(with: try! JSONEncoder().encode(testVersion))

        let expectation = expectation(description: "Waiting for completion handler.")
        var result: Result<Void, Error>?

        sut.verifyVersion(using: session) {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        switch result {
        case .success:
            XCTFail("Verification should fail!")
        case .failure(let error):
            XCTAssertEqual(error, Error.requiresUpdate)
        case .none:
            XCTFail("Result should have a value!")
        }
    }

    func testNetworkFailureWhileTryingToVerify() {
        let session = URLSession.makeMockSession(with: nil)

        let expectation = expectation(description: "Waiting for completion handler.")
        var result: Result<Void, Error>?

        sut.verifyVersion(using: session) {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        switch result {
        case .success:
            XCTFail("Verification should fail!")
        case .failure(let error):
            XCTAssertEqual(error, Error.verificationFailure)
        case .none:
            XCTFail("Result should have a value!")
        }
    }
}
