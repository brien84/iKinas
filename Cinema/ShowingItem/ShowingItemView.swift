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

                    VStack {
                        #warning("Fix force unwrap!")
                        Text(viewStore.showing.parentMovie!.title)
                            .font(.headline)
                            .lineLimit(2)
                            .foregroundColor(.primaryElement)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        #warning("Fix force unwrap!")
                        Text(viewStore.showing.parentMovie!.originalTitle)
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundColor(.secondaryElement)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .trailing) {
                        Text(viewStore.showing.date.asString(.timeOfDay))
                            .foregroundColor(.primaryElement)
                            .font(.title3)

                        Image(viewStore.showing.venue.rawValue)
                    }

                }
                .padding(.padding)
                .onTapGesture {
                    viewStore.send(.didSelectShowing(viewStore.showing))
                }

            }
        }
    }
}

private extension CGFloat {
    static let cornerRadius: CGFloat = 10
    static let height: CGFloat = 75
    static let width: CGFloat = 75
    static let padding: CGFloat = 8
}

struct ShowingItemView_Previews: PreviewProvider {
    static let movie = Movie()

    static let store = Store(
        initialState: ShowingItem.State(id: UUID(), showing: Showing(parentMovie: movie)),
        reducer: ShowingItem()
    )

    static var previews: some View {
        ShowingItemView(store: store)
            .fixedSize(horizontal: false, vertical: true)
    }
}
