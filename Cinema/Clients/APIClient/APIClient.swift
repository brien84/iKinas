//
//  APIClient.swift
//  Cinema
//
//  Created by Marius on 2023-06-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation
import OrderedCollections

struct APIClient {
    var fetch: (City, OrderedSet<Venue>) -> EffectTask<Response>
    var getShowings: () -> IdentifiedArrayOf<Showing.State>

    enum Response: Equatable {
        case success
        case failure(APIClient.Error)
    }

    enum Error: Swift.Error, Equatable {
        case decoding
        case network
        case requiresUpdate
    }
}

extension APIClient: TestDependencyKey {
    static let previewValue = Self(
        fetch: { _, _ in
            EffectTask.task {
                .success
            }
        },
        getShowings: {
            stride(from: 1, to: 50, by: 1).map { index in
                Previews.createShowing(
                    date: Date(timeIntervalSinceNow: index * .hour),
                    title: "Movie \(index)"
                )
            }.convertToIdentifiedArray()
        }
    )

    static let testValue = Self(
        fetch: { _, _ in unimplemented("\(Self.self).fetch") },
        getShowings: { unimplemented("\(Self.self).getShowings") }
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
