//
//  ShowingItemView.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ShowingItemView: View {
    let store: StoreOf<ShowingItem>

    @State private var isBeingPressed = false

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground

                HStack {
                    NetworkImageView(store: store.scope(
                        state: \.networkImage,
                        action: ShowingItem.Action.networkImage
                    ))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Self.width, height: Self.height)
                    .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))

                    ShowingTitleView(showing: viewStore.showing)

                    VStack(alignment: .trailing) {
                        Text(viewStore.showing.date.asString(.timeOfDay))
                            .foregroundColor(.primaryElement)
                            .font(.title3.bold())

                        Image(viewStore.showing.venue.rawValue)
                    }

                }
                .opacity(isBeingPressed ? Self.longPressOpacity : 1)
                .scaleEffect(isBeingPressed ? Self.longPressScaleEffect : 1)
            }
            .onTapGesture {
                viewStore.send(.didSelectShowing(viewStore.showing))
            }
            .onLongPressGesture(perform: { }, onPressingChanged: { isPressing in
                withAnimation(Self.longPressAnimation) {
                    isBeingPressed = isPressing
                }
            })
        }
    }
}

private struct ShowingTitleView: View {
    private let title: String
    private let originalTitle: String

    init(showing: Showing) {
        self.title = showing.parentMovie?.title ?? ""
        self.originalTitle = showing.parentMovie?.originalTitle ?? ""
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

    static let longPressAnimation: Animation = .spring(
        response: 0.5,
        dampingFraction: 0.5
    )

    static let longPressOpacity: CGFloat = 0.95
    static let longPressScaleEffect: CGFloat = 0.95
}

// MARK: - Previews

struct ShowingItemView_Previews: PreviewProvider {
    static let movies = [
        Movie(title: String(repeating: "A", count: 10), originalTitle: String(repeating: "A", count: 10), showings: [Showing()]),
        Movie(title: String(repeating: "A", count: 50), originalTitle: String(repeating: "A", count: 50), showings: [Showing()]),
        Movie(title: String(repeating: "A", count: 10), originalTitle: String(repeating: "B", count: 10), showings: [Showing()]),
        Movie(title: String(repeating: "A", count: 50), originalTitle: String(repeating: "B", count: 50), showings: [Showing()]),
        Movie(title: String(repeating: "A", count: 50), originalTitle: String(repeating: "B", count: 10), showings: [Showing()]),
        Movie(title: String(repeating: "A", count: 10), originalTitle: String(repeating: "B", count: 50), showings: [Showing()])
    ]

    static let items = [
        ShowingItem.State(id: UUID(), showing: movies[0].showings[0]),
        ShowingItem.State(id: UUID(), showing: movies[1].showings[0]),
        ShowingItem.State(id: UUID(), showing: movies[2].showings[0]),
        ShowingItem.State(id: UUID(), showing: movies[3].showings[0]),
        ShowingItem.State(id: UUID(), showing: movies[4].showings[0]),
        ShowingItem.State(id: UUID(), showing: movies[5].showings[0])
    ]

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            VStack {
                ShowingItemView(store: Store(initialState: items[0], reducer: ShowingItem()))
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)

                ShowingItemView(store: Store(initialState: items[1], reducer: ShowingItem()))
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)

                ShowingItemView(store: Store(initialState: items[2], reducer: ShowingItem()))
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)

                ShowingItemView(store: Store(initialState: items[3], reducer: ShowingItem()))
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)

                ShowingItemView(store: Store(initialState: items[4], reducer: ShowingItem()))
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)

                ShowingItemView(store: Store(initialState: items[5], reducer: ShowingItem()))
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
