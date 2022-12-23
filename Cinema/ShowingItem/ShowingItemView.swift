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
                    NetworkImageViewV2(store: store.scope(
                        state: \.networkImage,
                        action: ShowingItem.Action.networkImage
                    ))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: .width, height: .height)
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))

                    ShowingTitleView(showing: viewStore.showing)

                    VStack(alignment: .trailing) {
                        Text(viewStore.showing.date.asString(.timeOfDay))
                            .foregroundColor(.primaryElement)
                            .font(.title3)

                        Image(viewStore.showing.venue.rawValue)
                    }

                }
                .opacity(isBeingPressed ? CGFloat.longPressOpacity : 1)
                .scaleEffect(isBeingPressed ? .longPressScaleEffect : 1)
            }
            .onTapGesture {
                viewStore.send(.didSelectShowing(viewStore.showing))
            }
            .onLongPressGesture(perform: { }, onPressingChanged: { isPressing in
                withAnimation(.longPressSpring) {
                    isBeingPressed = isPressing
                }
            })
        }
    }
}

private struct ShowingTitleView: View {
    private let title: String
    private let originalTitle: String

    #warning("Fix force unwrap!")
    init(showing: Showing) {
        self.title = showing.parentMovie!.title
        self.originalTitle = showing.parentMovie!.originalTitle
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

private extension Animation {
    static let longPressSpring = Animation.spring(
        response: 0.5,
        dampingFraction: 0.5
    )
}

private extension CGFloat {
    static let cornerRadius: CGFloat = 10
    static let height: CGFloat = 75
    static let width: CGFloat = 75

    static let longPressOpacity: CGFloat = 0.95
    static let longPressScaleEffect: CGFloat = 0.95
}

struct ShowingItemView_Previews: PreviewProvider {
    static let movies = [
        Movie(title: String(repeating: "A", count: 10), originalTitle: String(repeating: "A", count: 10)),
        Movie(title: String(repeating: "A", count: 50), originalTitle: String(repeating: "A", count: 50)),
        Movie(title: String(repeating: "A", count: 10), originalTitle: String(repeating: "B", count: 10)),
        Movie(title: String(repeating: "A", count: 50), originalTitle: String(repeating: "B", count: 50)),
        Movie(title: String(repeating: "A", count: 50), originalTitle: String(repeating: "B", count: 10)),
        Movie(title: String(repeating: "A", count: 10), originalTitle: String(repeating: "B", count: 50))
    ]

    static let items = [
        ShowingItem.State(id: UUID(), showing: Showing(parentMovie: movies[0])),
        ShowingItem.State(id: UUID(), showing: Showing(parentMovie: movies[1])),
        ShowingItem.State(id: UUID(), showing: Showing(parentMovie: movies[2])),
        ShowingItem.State(id: UUID(), showing: Showing(parentMovie: movies[3])),
        ShowingItem.State(id: UUID(), showing: Showing(parentMovie: movies[4])),
        ShowingItem.State(id: UUID(), showing: Showing(parentMovie: movies[5]))
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
