//
//  NetworkImageTests.swift
//  CinemaTests
//
//  Created by Marius on 2022-12-18.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class NetworkImageTests: XCTestCase {

    func testFetchingImageSuccessfully() async {
        let store = TestStore(
            initialState: NetworkImage.State(url: URL(string: "test.com")!),
            reducer: NetworkImage()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        let testImage = UIImage(named: "posterPreview")!
        store.dependencies.imageClient.fetch = { _ in
            EffectPublisher(value: testImage)
        }

        await store.send(.fetch) {
            $0.isFetching = true
        }

        await mainQueue.advance(by: .seconds(1))

        await store.receive(.imageClient(.success(testImage))) {
            $0.isFetching = false
            $0.image = testImage
        }
    }

    func testFetchingImageUnsuccessfully() async {
        let store = TestStore(
            initialState: NetworkImage.State(url: URL(string: "test.com")!),
            reducer: NetworkImage()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        store.dependencies.imageClient.fetch = { _ in
            EffectPublisher(error: ImageClient.Failure())
        }

        await store.send(.fetch) {
            $0.isFetching = true
        }

        await mainQueue.advance(by: .seconds(1))

        await store.receive(.imageClient(.failure(ImageClient.Failure()))) {
            $0.isFetching = false
            $0.image = UIImage(named: "posterDefault")
        }
    }

    func testPassingOptionalURLSetsDefaultImage() async {
        let store = TestStore(
            initialState: NetworkImage.State(url: nil),
            reducer: NetworkImage()
        )

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        await store.send(.fetch) {
            $0.image = UIImage(named: "posterDefault")
        }
    }

}
