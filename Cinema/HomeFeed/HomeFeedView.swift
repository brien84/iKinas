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

    @State private var headerFrame: CGRect = CGRect()
    @State private var viewFrame: CGRect = CGRect()

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: .zero) {
                        HeaderView(store: store)
                            .background(FrameGetter(frame: $headerFrame))
                            .id(ScrollToTop.id)

                        if !viewStore.upcoming.isEmpty {
                            VStack(spacing: Self.verticalSpacing) {
                                UpcomingListView(store: store)
                                    .transition(.blurryScale(anchor: .leading), isActive: isTransitioning)

                                FeaturedListView(store: store)
                                    .transition(.blurryScale(anchor: .leading), isActive: isTransitioning)
                            }
                            .padding(.bottom)
                        } else {
                            EmptyErrorView(
                                title: "nieko nerodo",
                                subtitle: "pasirinkite kitus teatrus"
                            )
                            .frame(
                                width: viewFrame.width,
                                height: viewFrame.height - headerFrame.height
                            )
                            .transition(.blur, isActive: isTransitioning)
                        }
                    }
                }
                .scrollTo(ScrollToTop(proxy: proxy), when: isTransitioning)
                .transition(.opacity, isActive: isTransitioning)
            }
            .controlTransition($with: $isTransitioning, when: viewStore.isTransitioning)
        }
        .background(FrameGetter(frame: $viewFrame))
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
            .padding(.bottom, Self.bottomPadding)
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
    static let bottomPadding: CGFloat = 16
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
