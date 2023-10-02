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
            ScrollView {
                VStack(spacing: .zero) {
                    HeaderView(store: store)
                }
            }
            .opacity(viewStore.isTransitioning ? 0 : 1)
        }
    }
}

private struct HeaderView: View {
    let store: StoreOf<HomeFeed>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: Self.verticalSpacing) {
                DateView(date: Date())

                HStack {
                    GreetingView()

                    Spacer()

                    SettingsButton {
                        viewStore.send(.settingsButtonDidTap)
                    }
                }
            }
            .padding([.horizontal, .top])
            .padding(.bottom, Self.bottomPadding)

            Divider()
                .padding(.bottom, Self.bottomPadding)
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

// MARK: - Constants

private extension HeaderView {
    static let bottomPadding: CGFloat = 8
    static let verticalSpacing: CGFloat = 8
}

// MARK: - Previews

struct HomeFeedView_Previews: PreviewProvider {
    static let store = Store(initialState: HomeFeed.State(), reducer: HomeFeed())

    static var previews: some View {
        HomeFeedView(store: store)
            .preferredColorScheme(.dark)
    }
}
