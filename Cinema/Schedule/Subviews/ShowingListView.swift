//
//  ShowingListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ShowingListView: View {
    let store: StoreOf<Schedule>

    var body: some View {
        LazyVStack(spacing: .zero) {
            ForEachStore(store.scope(
                state: \.showingItems,
                action: Schedule.Action.showingItem(id:action:)
            )) {
                ShowingItemView(store: $0)
            }
        }
    }
}

private struct ShowingItemView: View {
    let store: StoreOf<ScheduleItem>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: .zero) {
                ShrinkOnPressView {
                    HStack {
                        NetworkImageView(store: store.scope(
                            state: \.networkImage,
                            action: ScheduleItem.Action.networkImage
                        ))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Self.width, height: Self.height)
                        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))

                        ShowingTitleView(showing: viewStore.showing)

                        VStack(alignment: .trailing) {
                            HStack {
                                Image(systemName: "view.3d")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.tertiaryElement)
                                    .opacity(viewStore.showing.is3D ? 1 : 0)

                                Text(viewStore.showing.date.toString(.timeOfDay))
                                    .font(.title2.weight(.medium))
                                    .foregroundColor(.primaryElement)
                            }

                            Image(viewStore.showing.venue.rawValue)
                        }
                    }
                    .background(Color.primaryBackground)
                    .onTapGesture {
                        viewStore.send(.didSelect)
                    }
                }

                Divider()
                    .padding(.vertical)
            }
            .padding(.horizontal)
        }
    }
}

private struct ShowingTitleView: View {
    private let title: String
    private let originalTitle: String

    init(showing: Showing) {
        self.title = showing.title
        self.originalTitle = showing.originalTitle
    }

    var body: some View {
        if title == originalTitle {
            Text(title)
                .font(.callout.bold())
                .foregroundColor(.primaryElement)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.callout.bold())
                    .lineLimit(2)
                    .foregroundColor(.primaryElement)

                Text(originalTitle)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.secondaryElement)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Constants

private extension ShowingItemView {
    static let cornerRadius: CGFloat = 10
    static let height: CGFloat = 75
    static let width: CGFloat = 75
}
