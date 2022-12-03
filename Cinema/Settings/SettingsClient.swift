//
//  SettingsClient.swift
//  Cinema
//
//  Created by Marius on 2022-12-03.
//  Copyright © 2022 Marius. All rights reserved.
//

import Dependencies
import Foundation
import OrderedCollections
import XCTestDynamicOverlay

struct SettingsClient {
    var load: @Sendable () async -> (City, OrderedSet<Venue>)
    var save: @Sendable (City, OrderedSet<Venue>) async -> Void
}

extension SettingsClient: DependencyKey {
    static let liveValue = Self(
        load: {
            (.vilnius, [])
        },
        save: { _, _ in

        }
    )
}

extension SettingsClient: TestDependencyKey {
    static let previewValue = Self(
        load: { (.vilnius, []) },
        save: { _, _ in }
    )

    static let testValue =  Self(
        load: unimplemented("\(Self.self).load"),
        save: unimplemented("\(Self.self).save")
    )
}

extension DependencyValues {
    var settingsClient: SettingsClient {
        get { self[SettingsClient.self] }
        set { self[SettingsClient.self] = newValue }
    }
}
