//
//  ExitButtonView.swift
//  Cinema
//
//  Created by Marius on 2022-12-04.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

private extension ExitButtonView {
    struct State: Equatable {

    }

    enum Action: Equatable {
        case closeSettings
        case saveSettings
    }
}

private extension Settings.State {
    var state: ExitButtonView.State {
        .init()
    }
}

private extension ExitButtonView.Action {
    var action: Settings.Action {
        switch self {
        case .closeSettings:
            return .closeSettings
        case .saveSettings:
            return .saveSettings
        }
    }
}

struct ExitButtonView: View {
    @Environment(\.presentationMode) var presentationMode

    let store: StoreOf<Settings>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            Button(
                action: {
                    viewStore.send(.saveSettings)
                    viewStore.send(.closeSettings)
                    presentationMode.wrappedValue.dismiss()
                },
                label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .padding(24)
                        .font(Font.title3.weight(.bold))
                        .foregroundColor(Color(.secondaryElement))
                        .background(
                            Circle()
                                .fill(Color(.primaryBackground))
                                .frame(width: 30)
                        )
                }
            )
            .accessibilityIdentifier(id)
        }
    }
}

// MARK: - UI Test IDs

private extension ExitButtonView {
    var id: String { "SettingsView-ExitButtonView" }
}

// MARK: - Previews

struct ExitButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ExitButtonView(store: Store(initialState: Settings.State(), reducer: Settings()))
    }
}
