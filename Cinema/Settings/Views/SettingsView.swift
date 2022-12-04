//
//  SettingsView.swift
//  Cinema
//
//  Created by Marius on 2022-12-03.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

private extension SettingsView {
    struct State: Equatable {
        var selectedCity: City
    }

    enum Action: Equatable {
        case didSelectCity(City)
        case loadSettings
    }
}

private extension Settings.State {
    var state: SettingsView.State {
        .init(selectedCity: self.selectedCity)
    }
}

private extension SettingsView.Action {
    var action: Settings.Action {
        switch self {
        case .didSelectCity(let city):
            return .didSelectCity(city)
        case .loadSettings:
            return .loadSettings
        }
    }
}

struct SettingsView: View {
    let store: StoreOf<Settings>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            ZStack {
                Color(.secondaryBackground)
                    .ignoresSafeArea()

                VStack {
                    Text("Pasirinkite miestą")
                        .font(.largeTitle)
                        .foregroundColor(.primaryElement)

                    CityListView(store: store)
                }
            }
            .onAppear {
                viewStore.send(.loadSettings)
            }
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: Store(initialState: Settings.State(), reducer: Settings()))
    }
}
