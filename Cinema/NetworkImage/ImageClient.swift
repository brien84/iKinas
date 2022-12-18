//
//  ImageClient.swift
//  Cinema
//
//  Created by Marius on 2022-12-18.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import XCTestDynamicOverlay

struct ImageClient {
    private static let cache = NSCache<NSURL, UIImage>()

    var fetch: (URL) -> Effect<UIImage, Failure>

    struct Failure: Error, Equatable { }
}

extension DependencyValues {
    var imageClient: ImageClient {
        get { self[ImageClient.self] }
        set { self[ImageClient.self] = newValue }
    }
}

extension ImageClient: DependencyKey {
    static let liveValue = Self(
        fetch: { _ in
            Effect(value: UIImage())
        }
    )

    static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch")
    )
}
