//
//  MovieClient.swift
//  Cinema
//
//  Created by Marius on 2022-12-21.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct MovieClient {
    var fetch: () -> Effect<[Movie], Error>
}

extension DependencyValues {
    var movieClient: MovieClient {
        get { self[MovieClient.self] }
        set { self[MovieClient.self] = newValue }
    }
}

extension MovieClient: DependencyKey {
    static let liveValue = Self(
        fetch: {
            Effect(value: [Movie]())
        }
    )

    static let previewValue = Self(
        fetch: {
            Effect(value: Array(repeating: Movie(), count: 5))
        }
    )

    static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch")
    )
}
