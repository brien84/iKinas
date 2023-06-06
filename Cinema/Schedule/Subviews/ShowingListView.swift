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
    let store: StoreOf<Schedule>

    var body: some View {
        LazyVStack(spacing: .zero) {
            ForEachStore(store.scope(
                state: \.showingItems,
                action: Schedule.Action.showingItem(id:action:)
            )) {
                ShowingItemView(store: $0)
            }
        }
    }
}

// MARK: - Previews

struct ShowingListView_Previews: PreviewProvider {
    static let movie = Movie(showings: Array(repeating: Showing(), count: 16))

    static let showingItems = {
        IdentifiedArray(uniqueElements: movie.showings.map { ShowingItem.State(id: UUID(), showing: $0) })
    }()

    static let store = Store(initialState: Schedule.State(showingItems: showingItems), reducer: Schedule())

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ScrollView {
                ShowingListView(store: store)
            }
        }
        .preferredColorScheme(.dark)
    }
}
