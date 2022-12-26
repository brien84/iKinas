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
                    presentationMode.wrappedValue.dismiss()
                },
                label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: .width)
                        .font(.title3.bold())
                        .padding(.padding)
                        .foregroundColor(.secondaryElement)
                        .background(
                            Circle()
                                .fill(Color.secondaryBackground)
                        )
                }
            )
        }
    }
}

private extension CGFloat {
    static let width: CGFloat = 12
    static let padding: CGFloat = 10
}

// MARK: - Previews

struct ExitButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ExitButtonView(store: Store(initialState: Settings.State(), reducer: Settings()))
    }
}
