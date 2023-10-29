//
//  FeaturedListView.swift
//  Cinema
//
//  Created by Marius on 2023-10-13.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct FeaturedListView: View {
    let store: StoreOf<HomeFeed>

    var body: some View {
        LazyVStack(spacing: Self.verticalSpacing) {
            ForEachStore(store.scope(
                state: \.featured,
                action: HomeFeed.Action.featured(id:action:)
            )) {
                FeaturedView(store: $0)
            }
        }
    }
}

private struct FeaturedView: View {
    let store: StoreOf<Featured>

    var body: some View {
        WithViewStore(store) { viewStore in
            ShrinkOnPressView {
                NetworkImageView(store: store.scope(
                    state: \.networkImage,
                    action: Featured.Action.networkImage
                ))
                .aspectRatio(contentMode: .fit)
            }
        }
    }
}

// MARK: - Constants

private extension FeaturedListView {
    static let verticalSpacing: CGFloat = 16
}
