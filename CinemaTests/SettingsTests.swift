//
//  SettingsTests.swift
//  CinemaTests
//
//  Created by Marius on 2022-12-04.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class SettingsTests: XCTestCase {

    func testSelectingCity() async {
        let store = TestStore(
            initialState: Settings.State(selectedCity: .vilnius, selectedVenues: [.forum]),
            reducer: Settings()
        )

        await store.send(.didSelectCity(.kaunas)) {
            $0.selectedCity = .kaunas
            $0.selectedVenues = City.kaunas.venues
        }
    }

    func testSelectingVenue() async {
        let store = TestStore(
            initialState: Settings.State(selectedCity: .vilnius, selectedVenues: [.forum]),
            reducer: Settings()
        )

        await store.send(.didSelectVenue(.multikino)) {
            $0.selectedCity = .vilnius
            $0.selectedVenues = [.forum, .multikino]
        }
    }

    func testDeselectingVenue() async {
        let store = TestStore(
            initialState: Settings.State(selectedCity: .vilnius, selectedVenues: [.forum, .multikino]),
            reducer: Settings()
        )

        await store.send(.didSelectVenue(.multikino)) {
            $0.selectedCity = .vilnius
            $0.selectedVenues = [.forum]
        }
    }

    func testLoadingSettings() async {
        let store = TestStore(
            initialState: Settings.State(selectedCity: .vilnius, selectedVenues: [.forum]),
            reducer: Settings()
        )

        store.dependencies.settingsClient.load = { (City.kaunas, City.kaunas.venues) }

        await store.send(.loadSettings)

        await store.receive(.didLoadSettings(.kaunas, City.kaunas.venues)) {
            $0.selectedCity = .kaunas
            $0.selectedVenues = City.kaunas.venues
        }

        await store.finish()
    }

    func testSavingSettings() async {
        let store = TestStore(
            initialState: Settings.State(selectedCity: .kaunas, selectedVenues: [.forum]),
            reducer: Settings()
        )

        store.dependencies.settingsClient.save = { city, venues in
            XCTAssertEqual(city, .kaunas)
            XCTAssertEqual(venues, [.forum])
        }

        await store.send(.saveSettings)

        await store.finish()
    }

}
