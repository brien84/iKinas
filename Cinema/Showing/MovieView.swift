//
//  MovieView.swift
//  Cinema
//
//  Created by Marius on 2023-11-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieView: View {
    let store: StoreOf<Showing>

    var body: some View {
        WithViewStore(store) { viewStore in
            ShrinkOnPressView {
                ZStack {
                    Color.primaryBackground

                    NetworkImageView(store: store.scope(
                        state: \.networkImage,
                        action: Showing.Action.networkImage
                    ))
                    .aspectRatio(Self.imageAspectRatio, contentMode: .fit)

                    VStack {
                        Spacer()

                        ZStack(alignment: .topLeading) {
                            Text(viewStore.title)
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
                .cornerRadius(Self.cornerRadius)
                .onTapGesture {
                    viewStore.send(.didSelect)
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

private extension MovieView {
    static let cornerRadius: CGFloat = 20
    static let imageAspectRatio: CGFloat = 2/3
}

// MARK: - Previews

struct MovieView_Previews: PreviewProvider {
    static let showings: [Showing.State] = {
        stride(from: 1, through: 20, by: 1).map { index in
            iKinas.Previews.createShowing(
                title: String(repeating: "Title", count: index)
            )
        }
    }()

    static var previews: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(showings) { showing in
                    MovieView(store: Store(
                        initialState: showing,
                        reducer: Showing()
                    ))
                    .aspectRatio(2/3, contentMode: .fit)
                    .padding(.horizontal, 8)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .preferredColorScheme(.dark)
    }
}
