//
//  MovieItemView.swift
//  Cinema
//
//  Created by Marius on 2022-12-17.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieItemView: View {
    let store: StoreOf<MovieItem>

    @State private var isBeingPressed = false

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground

                NetworkImageViewV2(store: store.scope(
                    state: \.networkImage,
                    action: MovieItem.Action.networkImage
                ))
                .aspectRatio(.imageAspectRatio, contentMode: .fit)

                VStack {
                    Spacer()

                    ZStack(alignment: .leading) {
                        Text(viewStore.movie.title)
                            .font(.headline)

                        Text(String(repeating: "Placeholder", count: 10))
                            .font(.headline)
                            .hidden()
                    }
                    .lineLimit(2)
                    .foregroundColor(.primaryElement)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadius, style: .continuous))
            .opacity(isBeingPressed ? CGFloat.longPressOpacity : 1)
            .scaleEffect(isBeingPressed ? .longPressScaleEffect : 1)
            .onTapGesture {
                viewStore.send(.didSelectMovie(viewStore.movie))
            }
            .onLongPressGesture(perform: { }, onPressingChanged: { isPressing in
                withAnimation(.longPressSpring) {
                    isBeingPressed = isPressing
                }
            })
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
    static let imageAspectRatio: CGFloat = 2/3
    static let longPressOpacity: CGFloat = 0.95
    static let longPressScaleEffect: CGFloat = 0.95

}

struct MovieItemView_Previews: PreviewProvider {
    static let store = Store(
        initialState: MovieItem.State(id: UUID(), movie: Movie()),
        reducer: MovieItem()
    )

    static var previews: some View {
        MovieItemView(store: store)
            .frame(width: 200, height: 300)
    }
}
