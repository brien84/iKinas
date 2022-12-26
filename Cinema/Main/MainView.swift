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
                    DateSelectorView(store: store.scope(
                        state: \.dateSelector,
                        action: Main.Action.dateSelector
                    ))

                    Divider()

                    ScheduleView(store: store.scope(
                        state: \.schedule,
                        action: Main.Action.schedule
                    ))
                }

                if viewStore.requiresToFetchMovies {
                    LoadingViewV2()
                }
            }
            .onAppear {
                if viewStore.requiresToFetchMovies {
                    viewStore.send(.fetchMovies)
                }
            }
        }
    }
}

private struct PassiveNavigationLink<Destination>: View where Destination: View {
    let isActive: Binding<Bool>
    let destination: () -> Destination

    var body: some View {
        NavigationLink(
            isActive: isActive,
            destination: {
                destination()
            },
            label: {
                EmptyView()
            }
        )
        .buttonStyle(.plain)
        .disabled(true)
        .hidden()
    }
}

struct MainView_Previews: PreviewProvider {
    static let store = Store(initialState: Main.State(), reducer: Main())

    static var previews: some View {
        MainView(store: store)
            .preferredColorScheme(.dark)
    }
}
