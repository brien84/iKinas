//
//  SimilarMoviesList.swift
//  Cinema
//
//  Created by Marius on 2023-11-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SimilarMoviesList: View {
    let store: StoreOf<ShowingInfo>

    var body: some View {
        WithViewStore(store) { _ in
            VStack(spacing: .zero) {
                SectionLabelView(text: "Panašūs")
                    .padding(.bottom, Self.bottomPadding)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Self.horizontalSpacing) {
                        ForEachStore(store.scope(
                            state: \.similar,
                            action: ShowingInfo.Action.similar(id:action:)
                        )) {
                            MovieView(store: $0)
                                .aspectRatio(Self.aspectRatio, contentMode: .fit)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
    }
}

// MARK: - Constants

private extension SimilarMoviesList {
    static let aspectRatio: CGFloat = 2/3
    static let bottomPadding: CGFloat = 8
    static let horizontalSpacing: CGFloat = 8
}
