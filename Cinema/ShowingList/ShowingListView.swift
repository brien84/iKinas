//
//  ShowingListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ShowingListView: View {
    let store: StoreOf<ShowingList>

    var body: some View {
        WithViewStore(store) { _ in
            LazyVStack {

            }
        }

    }
}

struct ShowingListView_Previews: PreviewProvider {
    static let store = Store(initialState: ShowingList.State(), reducer: ShowingList())

    static var previews: some View {
        ShowingListView(store: store)
            .preferredColorScheme(.dark)
    }
}
