//
//  HomeFeedView.swift
//  Cinema
//
//  Created by Marius on 2023-04-28.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct HomeFeedView: View {
    let store: StoreOf<HomeFeed>

    var body: some View {
        WithViewStore(store) { _ in

        }
    }
}

// MARK: - Previews

struct HomeFeedView_Previews: PreviewProvider {
    static let store = Store(initialState: HomeFeed.State(), reducer: HomeFeed())

    static var previews: some View {
        HomeFeedView(store: store)
    }
}
