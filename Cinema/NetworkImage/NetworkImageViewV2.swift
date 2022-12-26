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
                if viewStore.image == nil {
                    viewStore.send(.fetch)
                }
            }
        }
    }
}

struct NetworkImageViewV2Previews: PreviewProvider {
    static let store = Store(
        initialState: NetworkImage.State(url: URL(string: "previ.ew")!),
        reducer: NetworkImage()
    )

    static var previews: some View {
        ZStack {
            Color.gray

            NetworkImageViewV2(store: store)
                .frame(width: 200, height: 300)
                .preferredColorScheme(.dark)
        }

    }
}
