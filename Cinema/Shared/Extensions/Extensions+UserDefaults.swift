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
    static let cityKey = "UserDefaultsCityKey"
    static let venuesKey = "UserDefaultsVenuesKey"

    func isFirstLaunch() -> Bool {
        guard
            self.string(forKey: Self.cityKey) != nil,
            self.array(forKey: Self.venuesKey) != nil
        else {
            return true
        }

        return false
    }

    func readCity() -> City {
        guard
            let rawValue = self.string(forKey: Self.cityKey),
            let city = City(rawValue: rawValue)
        else {
            return .vilnius
        }

        return city
    }

    func readVenues() -> OrderedSet<Venue> {
        guard let rawValues = self.array(forKey: Self.venuesKey) as? [String]
        else { return self.readCity().venues }

        let venues = OrderedSet(rawValues.compactMap { Venue(rawValue: $0) })
        guard !venues.isEmpty else { return self.readCity().venues }

        return venues
    }

    func save(city: City, venues: OrderedSet<Venue>) {
        self.set(city.rawValue, forKey: Self.cityKey)
        self.set(venues.map { $0.rawValue }, forKey: Self.venuesKey)
    }
}
