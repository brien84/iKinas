//
//  Settings.swift
//  Cinema
//
//  Created by Marius on 2022-12-03.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import OrderedCollections

struct Settings: ReducerProtocol {
    struct State: Equatable {
        var selectedCity: City = .vilnius
        var selectedVenues: OrderedSet<Venue> = OrderedSet(City.vilnius.venues)
    }

    enum Action: Equatable {
        case didSelectCity(City)
        case didSelectVenue(Venue)
        case loadSettings
        case saveSettings
        case settingsClient(Result<SettingsClient.Settings, Never>)
    }

    @Dependency(\.settingsClient) var settingsClient

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {

        case .didSelectCity(let city):
            state.selectedCity = city
            state.selectedVenues = city.venues
            return .none

        case .didSelectVenue(let venue):
            if state.selectedVenues.contains(venue) {
                state.selectedVenues.remove(venue)
            } else {
                state.selectedVenues.append(venue)
            }
            return .none

        case .loadSettings:
            return settingsClient.load()
                .catchToEffect(Action.settingsClient)

        case .saveSettings:
            let city = state.selectedCity
            let venues = state.selectedVenues
            return settingsClient.save(city, venues)
                .fireAndForget()

        case .settingsClient(.success(let settings)):
            state.selectedCity = settings.city
            state.selectedVenues = settings.venues
            return .none
        }
    }
}
