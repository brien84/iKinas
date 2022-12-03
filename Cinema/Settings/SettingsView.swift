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

    }

    enum Action: Equatable {
        case action
    }
}

private extension Settings.State {
    var state: SettingsView.State {
        .init()
    }
}

private extension SettingsView.Action {
    var action: Settings.Action {
        .someAction
    }
}

struct SettingsView: View {
    let store: StoreOf<Settings>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { _ in

        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: Store(initialState: Settings.State(), reducer: Settings()))
    }
}
