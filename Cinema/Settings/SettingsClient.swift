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
    var load: () -> Effect<SettingsClient.Settings, Never>
    var save: (City, OrderedSet<Venue>) -> Effect<Void, Never>

    struct Settings: Equatable {
        let city: City
        let venues: OrderedSet<Venue>
    }
}

extension SettingsClient: DependencyKey {
    static let liveValue = Self(
        load: {
            guard
                let rawValue = UserDefaults.standard.string(forKey: UserDefaults.cityKey),
                let city = City(rawValue: rawValue)
            else {
                return Effect(value: SettingsClient.Settings(city: .vilnius, venues: City.vilnius.venues))
            }

            guard
                let rawValues = UserDefaults.standard.array(forKey: UserDefaults.venuesKey) as? [String]
            else {
                return Effect(value: SettingsClient.Settings(city: city, venues: city.venues))
            }

            let venues = OrderedSet(rawValues.compactMap { Venue(rawValue: $0) })

            return Effect(value: SettingsClient.Settings(city: city, venues: venues))
        },
        save: { city, venues in
            .fireAndForget {
                UserDefaults.standard.set(city.rawValue, forKey: UserDefaults.cityKey)
                UserDefaults.standard.set(venues.map { $0.rawValue }, forKey: UserDefaults.venuesKey)
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
        load: {
            let settings = SettingsClient.Settings(city: .vilnius, venues: City.vilnius.venues)
            return Effect(value: settings)
        },
        save: { _, _ in
            return Effect(value: ())
        }
    )

    static let testValue =  Self(
        load: unimplemented("\(Self.self).load"),
        save: unimplemented("\(Self.self).save")
    )
}
