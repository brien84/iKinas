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
            guard
                let rawValue = UserDefaults.standard.string(forKey: UserDefaults.cityKey),
                let city = City(rawValue: rawValue)
            else {
                return (.vilnius, City.vilnius.venues)
            }

            guard
                let rawValues = UserDefaults.standard.array(forKey: UserDefaults.venuesKey) as? [String]
            else {
                return (city, city.venues)
            }

            let venues = OrderedSet(rawValues.compactMap { Venue(rawValue: $0) })

            return (city, venues)
        },
        save: { city, venues in
            UserDefaults.standard.set(city.rawValue, forKey: UserDefaults.cityKey)
            UserDefaults.standard.set(venues.map { $0.rawValue }, forKey: UserDefaults.venuesKey)
        }
    )
}

extension SettingsClient: TestDependencyKey {
    static let previewValue = Self(
        load: { (City.vilnius, City.vilnius.venues) },
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
