//
//  UserDefaultsClient.swift
//  Cinema
//
//  Created by Marius on 2023-04-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation
import OrderedCollections

struct UserDefaultsClient {
    var isFirstLaunch: () -> Bool
    var shouldAskForReview: () -> Bool
    var getCity: () -> City
    var setCity: (City) -> Void
    var getVenues: () -> OrderedSet<Venue>
    var setVenues: (OrderedSet<Venue>) -> Void
}

extension UserDefaultsClient: TestDependencyKey {
    static let previewValue: Self = {
        let defaults = UserDefaults(suiteName: "UserDefaultsClient.preview")!
        defaults.removePersistentDomain(forName: "UserDefaultsClient.preview")

        return Self(
            isFirstLaunch: {
                Self.isFirstLaunch(in: defaults)
            },
            shouldAskForReview: {
                true
            },
            getCity: {
                Self.getCity(in: defaults)
            },
            setCity: { city in
                Self.setCity(city, in: defaults)
            },
            getVenues: {
                Self.getVenues(in: defaults)
            },
            setVenues: { venues in
                Self.setVenues(venues, in: defaults)
            }
        )
    }()

    static let testValue: Self = Self(
        isFirstLaunch: unimplemented("\(Self.self).isFirstLaunch"),
        shouldAskForReview: unimplemented("\(Self.self).shouldAskForReview"),
        getCity: unimplemented("\(Self.self).getCity"),
        setCity: unimplemented("\(Self.self).setCity"),
        getVenues: unimplemented("\(Self.self).getVenues"),
        setVenues: unimplemented("\(Self.self).setVenues")
    )
}

extension UserDefaultsClient {
    static let cityKey = "UserDefaultsCityKey"
    static let venuesKey = "UserDefaultsVenuesKey"
    static let lastUsageDateKey = "UserDefaultsUsageCountKey"
    static let usageCountKey = "UserDefaultsUsageCountKey"

    static func isFirstLaunch(in defaults: UserDefaults) -> Bool {
        if defaults.string(forKey: Self.cityKey) == nil { return true }
        if defaults.array(forKey: Self.venuesKey) == nil { return true }
        return false
    }

    static func getCity(in defaults: UserDefaults) -> City {
        guard let rawValue = defaults.string(forKey: Self.cityKey) else { return .vilnius }
        guard let city = City(rawValue: rawValue) else { return .vilnius }
        return city
    }

    static func setCity(_ city: City, in defaults: UserDefaults) {
        defaults.set(city.rawValue, forKey: Self.cityKey)
    }

    static func getVenues(in defaults: UserDefaults) -> OrderedSet<Venue> {
        guard let rawValues = defaults.array(forKey: Self.venuesKey) as? [String]
        else { return Self.getCity(in: defaults).venues }

        let venues = OrderedSet(rawValues.compactMap { Venue(rawValue: $0) })
        guard !venues.isEmpty else { return Self.getCity(in: defaults).venues }

        return venues
    }

    static func setVenues(_ venues: OrderedSet<Venue>, in defaults: UserDefaults) {
        defaults.set(venues.map { $0.rawValue }, forKey: Self.venuesKey)
    }

    static func getLastUsageDate(in defaults: UserDefaults) -> Date {
        defaults.object(forKey: Self.lastUsageDateKey) as? Date ?? Date()
    }

    static func setLastUsageDate(_ date: Date, in defaults: UserDefaults) {
        defaults.setValue(date, forKey: Self.lastUsageDateKey)
    }

    static func getUsageCount(in defaults: UserDefaults) -> Int {
        defaults.integer(forKey: Self.usageCountKey)
    }

    static func setUsageCount(_ count: Int, in defaults: UserDefaults) {
        defaults.setValue(count, forKey: Self.usageCountKey)
    }
}

extension DependencyValues {
    var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
