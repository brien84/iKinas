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
    }
}
