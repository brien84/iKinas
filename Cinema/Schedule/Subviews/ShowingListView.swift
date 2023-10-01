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
                state: \.showings,
                action: Schedule.Action.showing(id:action:)
            )) {
                ShowingView(store: $0)
            }
        }
    }
}

private struct ShowingView: View {
    let store: StoreOf<Showing>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: .zero) {
                ShrinkOnPressView {
                    HStack {
                        NetworkImageView(store: store.scope(
                            state: \.networkImage,
                            action: Showing.Action.networkImage
                        ))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Self.width, height: Self.height)
                        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))

                        TitleView(showing: viewStore.state)

                        VStack(alignment: .trailing) {
                            HStack {
                                Image(systemName: "view.3d")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.tertiaryElement)
                                    .opacity(viewStore.is3D ? 1 : 0)

                                Text(viewStore.date.formatted(.timeOfDay))
                                    .font(.title2.weight(.medium))
                                    .foregroundColor(.primaryElement)
                            }

                            Image(viewStore.venue.rawValue)
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

private struct TitleView: View {
    private let title: String
    private let originalTitle: String

    init(showing: Showing.State) {
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

private extension ShowingView {
    static let cornerRadius: CGFloat = 10
    static let height: CGFloat = 75
    static let width: CGFloat = 75
}
