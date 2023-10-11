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

    @State private var isTransitioning = true

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: .zero) {
                    HeaderView(store: store)

                    UpcomingListView(store: store)
                        .transition(.blurryScale(anchor: .leading), isActive: isTransitioning)
                }
            }
            .transition(.opacity, isActive: isTransitioning)
            .controlTransition($with: $isTransitioning, when: viewStore.isTransitioning)
        }
    }
}

private struct HeaderView: View {
    let store: StoreOf<HomeFeed>

    @State private var isTransitioning = true

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: Self.verticalSpacing) {
                DateView(date: Date())
                    .transition(.scale, isActive: isTransitioning)

                HStack {
                    GreetingView()
                        .transition(.scale, isActive: isTransitioning)

                    Spacer()

                    SettingsButton {
                        viewStore.send(.settingsButtonDidTap)
                    }
                    .transition(.blur, isActive: isTransitioning)
                }
            }
            .padding([.horizontal, .top])
            .padding(.bottom, Self.bottomPadding)
            .controlTransition($with: $isTransitioning, when: viewStore.isTransitioning)

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
    static let showings: IdentifiedArrayOf<Showing.State> = {
        stride(from: 1, through: 5, by: 1).map { _ in
            iKinas.Previews.createShowing()
        }.convertToIdentifiedArray()
    }()

    static let store = Store(
        initialState: HomeFeed.State(showings: showings),
        reducer: HomeFeed()
    )

    static var previews: some View {
        HomeFeedView(store: store)
            .preferredColorScheme(.dark)
    }
}
