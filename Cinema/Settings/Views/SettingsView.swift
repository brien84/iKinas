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
                Color(.primaryBackground)
                    .ignoresSafeArea()

                VStack {
                    Text("Pasirinkite miestą")
                        .font(.largeTitle)
                        .foregroundColor(.primaryElement)

                    CityListView(store: store)
                }
                .modifier(Scale320X568Screen())
            }
            .overlay(
                ExitButtonView(store: store)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding()
            )
            .onAppear {
                viewStore.send(.loadSettings)
            }
        }
    }
}

/// Scales down the view if screen size of the device is 320x568.
///
/// Used on iPod Touch and iPhone SE 1st Gen devices.
/// Can be deleted when iOS 15 is no longer supported.
private struct Scale320X568Screen: ViewModifier {
    private var isActive: Bool {
        UIScreen.main.bounds.size == CGSize(width: 320, height: 568)
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 0.9 : 1)
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: Store(initialState: Settings.State(), reducer: Settings()))
    }
}
