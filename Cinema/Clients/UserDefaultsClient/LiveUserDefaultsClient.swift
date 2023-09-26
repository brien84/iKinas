//
//  LiveUserDefaultsClient.swift
//  Cinema
//
//  Created by Marius on 2023-09-26.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation
import OrderedCollections

extension UserDefaultsClient: DependencyKey {
    static let liveValue: Self = {
        let defaults = UserDefaults.standard

        return Self(
            isFirstLaunch: {
                if CommandLine.isUITesting { return false }
                if CommandLine.isUITestingFirstLaunch { return true }
                return Self.isFirstLaunch(in: defaults)
            },
            getCity: {
                if CommandLine.isUITesting { return .vilnius }
                return Self.getCity(in: defaults)
            },
            setCity: { city in
                Self.setCity(city, in: defaults)
            },
            getVenues: {
                if CommandLine.isUITesting { return City.vilnius.venues }
                return Self.getVenues(in: defaults)
            },
            setVenues: { venues in
                Self.setVenues(venues, in: defaults)
            }
        )
    }()
}
