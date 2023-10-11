//
//  MovieListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-17.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieListView: View {
    let store: StoreOf<Schedule>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Self.horizontalSpacing) {
                        ForEachStore(store.scope(
                            state: \.movies,
                            action: Schedule.Action.movie(id:action:)
                        )) {
                            MovieView(store: $0)
                                .aspectRatio(Self.aspectRatio, contentMode: .fit)
                        }
                    }
                    .id(ScrollToTop.id)
                    .padding(.horizontal)
                }
                .scrollTo(ScrollToTop(proxy: proxy, anchor: .leading), when: viewStore.isTransitioning)
            }
        }
    }
}

private struct MovieView: View {
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

private extension MovieListView {
    static let aspectRatio: CGFloat = 2/3
    static let horizontalSpacing: CGFloat = 8
}

private extension MovieView {
    static let cornerRadius: CGFloat = 20
    static let imageAspectRatio: CGFloat = 2/3
}
