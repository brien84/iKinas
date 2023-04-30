//
//  SettingsClient.swift
//  Cinema
//
//  Created by Marius on 2022-12-03.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation
import OrderedCollections
import XCTestDynamicOverlay

struct SettingsClient {
    var isFirstLaunch: () -> Bool
    var load: () -> Effect<SettingsClient.Settings, Never>
    var save: (City, OrderedSet<Venue>) -> Effect<Void, Never>

    struct Settings: Equatable {
        let city: City
        let venues: OrderedSet<Venue>
    }
}

extension SettingsClient: DependencyKey {
    static let liveValue = Self(
        isFirstLaunch: {
            UserDefaults.standard.isFirstLaunch()
        },
        load: {
            let city = UserDefaults.standard.readCity()
            let venues = UserDefaults.standard.readVenues()
            return Effect(value: SettingsClient.Settings(city: city, venues: venues))
        },
        save: { city, venues in
            .fireAndForget {
                UserDefaults.standard.save(city: city, venues: venues)
            }
        }
    )
}

extension DependencyValues {
    var settingsClient: SettingsClient {
        get { self[SettingsClient.self] }
        set { self[SettingsClient.self] = newValue }
    }
}

extension SettingsClient: TestDependencyKey {
    static let previewValue = Self(
        isFirstLaunch: {
            false
        },
        load: {
            let settings = SettingsClient.Settings(city: .vilnius, venues: City.vilnius.venues)
            return Effect(value: settings)
        },
        save: { _, _ in
            return Effect(value: ())
        }
    )

    static let testValue =  Self(
        isFirstLaunch: unimplemented("\(Self.self).isFirstLaunch"),
        load: unimplemented("\(Self.self).load"),
        save: unimplemented("\(Self.self).save")
    )
}
