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
        case didLoadSettings(City, OrderedSet<Venue>)
        case didSelectCity(City)
        case didSelectVenue(Venue)
        case loadSettings
        case saveSettings
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.settingsClient) var settingsClient

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {

        case .didLoadSettings(let city, let venues):
            state.selectedCity = city
            state.selectedVenues = venues
            return .none

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
            return .task {
                let (city, venues) = await settingsClient.load()
                return .didLoadSettings(city, venues)
            }

        case .saveSettings:
            return .fireAndForget { [city = state.selectedCity, venues = state.selectedVenues] in
                await settingsClient.save(city, venues)
            }
            .receive(on: mainQueue)
            .eraseToEffect()
        }
    }
}
