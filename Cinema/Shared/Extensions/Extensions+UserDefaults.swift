//
//  Extensions+UserDefaults.swift
//  Cinema
//
//  Created by Marius on 2023-01-11.
//  Copyright © 2023 Marius. All rights reserved.
//

import Foundation
import OrderedCollections

extension UserDefaults {
    private static let cityKey = "UserDefaultsCityKey"
    private static let venuesKey = "UserDefaultsVenuesKey"

    func isFirstLaunch() -> Bool {
        if CommandLine.isUITesting { return false }
        if CommandLine.isUITestingFirstLaunch { return true }

        guard
            self.string(forKey: Self.cityKey) != nil,
            self.array(forKey: Self.venuesKey) != nil
        else {
            return true
        }

        return false
    }

    func readCity() -> City {
        if CommandLine.isUITesting { return City.vilnius }

        guard
            let rawValue = self.string(forKey: Self.cityKey),
            let city = City(rawValue: rawValue)
        else {
            return .vilnius
        }

        return city
    }

    func readVenues() -> OrderedSet<Venue> {
        if CommandLine.isUITesting { return City.vilnius.venues }

        guard let rawValues = self.array(forKey: Self.venuesKey) as? [String]
        else { return self.readCity().venues }

        let venues = OrderedSet(rawValues.compactMap { Venue(rawValue: $0) })
        guard !venues.isEmpty else { return self.readCity().venues }

        return venues
    }

    func save(city: City, venues: OrderedSet<Venue>) {
        if CommandLine.isUITesting { return }

        self.set(city.rawValue, forKey: Self.cityKey)
        self.set(venues.map { $0.rawValue }, forKey: Self.venuesKey)
    }
}
