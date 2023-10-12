//
//  ShowingView.swift
//  Cinema
//
//  Created by Marius on 2023-10-05.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ShowingView: View {
    let store: StoreOf<Showing>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Self.verticalSpacing) {
                ShrinkOnPressView {
                    HStack {
                        PosterView(store: store)

                        TitleView(showing: viewStore.state)

                        InfoView(showing: viewStore.state)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.didSelect)
                    }
                }

                Divider()
            }
        }
    }
}

private struct InfoView: View {
    private let date: Date
    private let is3D: Bool
    private let venue: Venue

    init(showing: Showing.State) {
        self.date = showing.date
        self.is3D = showing.is3D
        self.venue = showing.venue
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: Self.verticalSpacing) {
            HStack {
                Image(systemName: "view.3d")
                    .font(.body.weight(.medium))
                    .foregroundColor(.tertiaryElement)
                    .opacity(is3D ? 1 : 0)

                Text(date.formatted(.timeOfDay))
                    .font(.title2.weight(.medium))
                    .foregroundColor(.primaryElement)
            }

            Image(venue.rawValue)
        }
        .scaleEffect(Self.scaleValue, anchor: .trailing)
    }
}

private struct PosterView: View {
    let store: StoreOf<Showing>

    var body: some View {
        NetworkImageView(store: store.scope(
            state: \.networkImage,
            action: Showing.Action.networkImage
        ))
        .aspectRatio(contentMode: .fill)
        .frame(width: Self.width, height: Self.height)
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
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
        VStack(alignment: .leading) {
            Text(title)
                .font(.callout.bold())
                .foregroundColor(.primaryElement)
                .lineLimit(2)

            if title != originalTitle {
                Text(originalTitle)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.secondaryElement)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Constants

private extension InfoView {
    static let scaleValue: CGFloat = 0.9
    static let verticalSpacing: CGFloat = 8
}

private extension PosterView {
    static let cornerRadius: CGFloat = 10
    static let height: CGFloat = 60
    static let width: CGFloat = 60
}

private extension ShowingView {
    static let verticalSpacing: CGFloat = 8
}

// MARK: - Previews

struct ShowingView_Previews: PreviewProvider {
    static let showings: [Showing.State] = {
        stride(from: 1, through: 20, by: 1).map { index in
            iKinas.Previews.createShowing(
                originalTitle: String(repeating: index % 2 == 0 ? "Title" : "OriginalTitle", count: index),
                title: String(repeating: "Title", count: index)
            )
        }
    }()

    static var previews: some View {
        ScrollView {
            LazyVStack {
                ForEach(showings) { showing in
                    ShowingView(store: Store(
                        initialState: showing,
                        reducer: Showing()
                    ))
                }
            }
            .padding(.horizontal)
        }
        .preferredColorScheme(.dark)
    }
}
