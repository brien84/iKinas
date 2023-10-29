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
                ZStack {
                    NetworkImageView(store: store.scope(
                        state: \.networkImage,
                        action: Featured.Action.networkImage
                    ))
                    .aspectRatio(contentMode: .fit)

                    VStack(alignment: .leading, spacing: Self.verticalSpacing) {
                        let isTitleEqualToOriginalTitle = viewStore.title == viewStore.originalTitle

                        Text(viewStore.label.uppercased())
                            .font(.subheadline.bold())
                            .foregroundColor(.tertiaryElement)
                            .lineLimit(1)

                        Text(viewStore.title)
                            .font(.title.bold())
                            .foregroundColor(.primaryElement)
                            .lineLimit(isTitleEqualToOriginalTitle ? 3 : 2)

                        if !isTitleEqualToOriginalTitle {
                            Text(viewStore.originalTitle)
                                .font(.subheadline)
                                .foregroundColor(.secondaryElement)
                                .lineLimit(1)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondaryBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                    RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .strokeBorder(Color.primaryElement, lineWidth: Self.lineWidth)
                }
                .aspectRatio(1, contentMode: .fit)
                .contentShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
                .cornerRadius(Self.cornerRadius)
                .padding(.horizontal)
                .onTapGesture {
                    viewStore.send(.didSelect)
                }
            }
        }
    }
}

// MARK: - Constants

private extension FeaturedListView {
    static let verticalSpacing: CGFloat = 16
}

private extension FeaturedView {
    static let cornerRadius: CGFloat = 15
    static let lineWidth: CGFloat = 3
    static let verticalSpacing: CGFloat = 8
}

// MARK: - Previews

struct FeaturedListView_Previews: PreviewProvider {
    static let featured: IdentifiedArrayOf<Featured.State> = {
        stride(from: 1, through: 20, by: 1).map { index in
            iKinas.Previews.createFeatured(
                originalTitle: String(repeating: index % 2 == 0 ? "Title " : "OriginalTitle ", count: index),
                title: String(repeating: "Title ", count: index)
            )
        }.convertToIdentifiedArray()
    }()

    static let store = Store(
        initialState: HomeFeed.State(featured: featured),
        reducer: HomeFeed()
    )

    static var previews: some View {
        ScrollView {
            FeaturedListView(store: store)
        }
        .background(Color.primaryBackground.ignoresSafeArea())
        .colorScheme(.dark)
    }
}
