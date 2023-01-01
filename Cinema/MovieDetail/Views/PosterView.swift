//
//  PosterView.swift
//  Cinema
//
//  Created by Marius on 2023-01-01.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct PosterView: View {
    let store: StoreOf<MovieDetail>

    var body: some View {
        NetworkImageViewV2(store: store.scope(
            state: \.networkImage,
            action: MovieDetail.Action.networkImage
        ))
        .frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width * Self.heightToWidthRatio
        )
        .aspectRatio(contentMode: .fit)
    }
}

// MARK: - Constants

private extension PosterView {
    static let heightToWidthRatio: CGFloat = 1.5
}

// MARK: - Previews

struct PosterView_Previews: PreviewProvider {
    static let store = Store(initialState: MovieDetail.State(movie: Movie()), reducer: MovieDetail())

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            PosterView(store: store)
                .preferredColorScheme(.dark)
        }
    }
}
