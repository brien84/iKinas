//
//  HomeFeedView.swift
//  Cinema
//
//  Created by Marius on 2023-04-28.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct HomeFeedView: View {
    let store: StoreOf<HomeFeed>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground
                    .edgesIgnoringSafeArea(.bottom)

                VStack {
                    SettingsButton {
                        viewStore.send(.settingsButtonDidTap)
                    }

                    Text("Welcome to HomeFeed!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primaryElement)
                        .padding()
                        .scaleEffect(viewStore.isTransitioning ? 0.75 : 1)
                }
            }
            .opacity(viewStore.isTransitioning ? 0 : 1)
        }
    }
}

private struct SettingsButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "gearshape")
                .font(.title2)
                .foregroundColor(.primaryElement)
        }
    }
}

// MARK: - Previews

struct HomeFeedView_Previews: PreviewProvider {
    static let store = Store(initialState: HomeFeed.State(), reducer: HomeFeed())

    static var previews: some View {
        HomeFeedView(store: store)
    }
}
