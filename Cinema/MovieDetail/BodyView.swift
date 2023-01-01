//
//  BodyView.swift
//  Cinema
//
//  Created by Marius on 2023-01-01.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct BodyView: View {
    let store: StoreOf<MovieDetail>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground

                VStack(spacing: 0) {
                    GenresView(genres: viewStore.movie.genres)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 8)

                    Divider()
                        .padding(.horizontal)
                }
            }
        }
    }
}
