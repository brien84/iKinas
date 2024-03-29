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
        let defaults: UserDefaults = {
            if !CommandLine.isUITesting {
                return UserDefaults.standard
            } else {
                guard let defaults = UserDefaults(suiteName: "UserDefaults.UITesting")
                else { fatalError("UserDefaults could not be initalized.") }
                defaults.removePersistentDomain(forName: "UserDefaults.UITesting")
                return defaults
            }
        }()

        return Self(
            isFirstLaunch: {
                Self.isFirstLaunch(in: defaults)
            },
            setAppVersion: {
                if let version = Bundle.main.version, let build = Bundle.main.build {
                    Self.setAppVersion(version + " (" + build + ")", in: defaults)
                } else {
                    Self.setAppVersion("1.0", in: defaults)
                }
            },
            shouldAskForReview: {
                var usageCount = Self.getUsageCount(in: defaults)
                if !Calendar.current.isDateInToday(getLastUsageDate(in: defaults)) {
                    Self.setLastUsageDate(Date(), in: defaults)
                    Self.setUsageCount(usageCount + 1, in: defaults)
                }
                usageCount = Self.getUsageCount(in: defaults)
                return usageCount == 5 || usageCount % 20 == 0
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
}
