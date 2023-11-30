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
                    .padding(.horizontal)
                    .id(ScrollToTop.id)
                }
                .scrollTo(ScrollToTop(proxy: proxy, anchor: .leading), when: viewStore.isTransitioning)
            }
        }
    }
}

// MARK: - Constants

private extension MovieListView {
    static let aspectRatio: CGFloat = 2/3
    static let horizontalSpacing: CGFloat = 8
}
