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

    var body: some View {
        WithViewStore(store) { viewStore in
            ShrinkOnPressView {
                ZStack {
                    Color.primaryBackground

                    NetworkImageView(store: store.scope(
                        state: \.networkImage,
                        action: MovieItem.Action.networkImage
                    ))
                    .aspectRatio(Self.imageAspectRatio, contentMode: .fit)

                    VStack {
                        Spacer()

                        ZStack(alignment: .topLeading) {
                            Text(viewStore.movie.title)
                                .font(.callout.bold())
                                .foregroundColor(.primaryElement)

                            Text(String(repeating: "Placeholder", count: 10))
                                .font(.callout.bold())
                                .hidden()
                        }
                        .lineLimit(2)
                        .foregroundColor(.primaryElement)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                        )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
                .onTapGesture {
                    viewStore.send(.didSelectMovie(viewStore.movie))
                }
            }
        }
    }
}

private struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

// MARK: - Constants

private extension MovieItemView {
    static let cornerRadius: CGFloat = 20
    static let imageAspectRatio: CGFloat = 2/3
}

// MARK: - Previews

struct MovieItemView_Previews: PreviewProvider {
    static let store = Store(
        initialState: MovieItem.State(id: UUID(), movie: Movie()),
        reducer: MovieItem()
    )

    static var previews: some View {
        MovieItemView(store: store)
            .frame(width: 200, height: 300)
            .preferredColorScheme(.dark)
    }
}
