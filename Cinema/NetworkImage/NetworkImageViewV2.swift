//
//  NetworkImageViewV2.swift
//  Cinema
//
//  Created by Marius on 2022-12-18.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct NetworkImageViewV2: View {
    let store: StoreOf<NetworkImage>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if viewStore.isFetching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryElement))
                }

                if let image = viewStore.image {
                    Image(uiImage: image)
                        .resizable()
                }
            }
            .onAppear {
                viewStore.send(.fetch)
            }
        }
    }
}
