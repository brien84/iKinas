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
                VStack(spacing: Self.verticalSpacing) {
                    HeaderView(store: store)

                    UpcomingListView(store: store)
                        .transition(.blurryScale(anchor: .leading), isActive: isTransitioning)

                    FeaturedListView(store: store)
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
                    .padding([.horizontal, .top])
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
                .padding(.horizontal)

                Divider()
            }
            .controlTransition($with: $isTransitioning, when: viewStore.isTransitioning)
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
    static let verticalSpacing: CGFloat = 8
}

private extension HomeFeedView {
    static let verticalSpacing: CGFloat = 16
}

// MARK: - Previews

struct HomeFeedView_Previews: PreviewProvider {
    static let featured: IdentifiedArrayOf<Featured.State> = {
        stride(from: 1, through: 5, by: 1).map { _ in
            iKinas.Previews.createFeatured()
        }.convertToIdentifiedArray()
    }()

    static let upcoming: IdentifiedArrayOf<Showing.State> = {
        stride(from: 1, through: 5, by: 1).map { _ in
            iKinas.Previews.createShowing()
        }.convertToIdentifiedArray()
    }()

    static let store = Store(
        initialState: HomeFeed.State(featured: featured, upcoming: upcoming),
        reducer: HomeFeed()
    )

    static var previews: some View {
        HomeFeedView(store: store)
            .background(Color.primaryBackground.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .onAppear {
                ViewStore(store).send(.toggleTransition)
            }
    }
}
