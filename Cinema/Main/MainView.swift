//
//  MainView.swift
//  Cinema
//
//  Created by Marius on 2022-12-20.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                PassiveNavigationLink(
                    isActive: viewStore.binding(
                        get: \.isNavigationToSettingsActive,
                        send: Main.Action.setNavigationToSettings(isActive:)
                    ),
                    destination: {
                        IfLetStore(
                            store.scope(
                                state: \.settings,
                                action: Main.Action.settings
                            ),
                            then: SettingsView.init(store:)
                        )
                    }
                )

                Color.primaryBackground
                    .edgesIgnoringSafeArea(.bottom)

                VStack(spacing: .zero) {
                    HStack(spacing: .zero) {
                        let isSelected = viewStore.isHomeFeedButtonSelected
                        HomeFeedButton {
                            viewStore.send(.didPressHomeFeedButton, animation: .default)
                        }
                        .foregroundColor(isSelected ? .tertiaryElement : .primaryElement)

                        Divider()

                        DateSelectorView(store: store.scope(
                            state: \.dateSelector,
                            action: Main.Action.dateSelector
                        ))
                        .disabled(viewStore.isFetching)
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    Divider()

                    if viewStore.isHomeFeedActive {
                        HomeFeedView(store: store.scope(
                            state: \.homeFeed,
                            action: Main.Action.homeFeed
                        ))
                    } else {
                        ScheduleView(store: store.scope(
                            state: \.schedule,
                            action: Main.Action.schedule
                        ))
                    }
                }

                if viewStore.isFetching {
                    LoadingView()
                }

                if viewStore.apiError == .network {
                    LoadingErrorView(.network) {
                        viewStore.send(.fetch, animation: .default)
                    }
                }

                if viewStore.apiError == .requiresUpdate {
                    LoadingErrorView(.requiresUpdate) {
                        UIApplication.shared.open(.appStore)
                    }
                }
            }
        }
    }
}

private struct HomeFeedButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "house")
                .padding(.horizontal)
                .padding(.vertical, Self.verticalPadding)
        }
    }
}

// MARK: - Constants

private extension HomeFeedButton {
    static let verticalPadding: CGFloat = 20
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
    static let store = Store(initialState: Main.State(), reducer: Main())

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            MainView(store: store)
                .preferredColorScheme(.dark)
                .onAppear {
                    ViewStore(store).send(.fetch)
                }
        }
    }
}
