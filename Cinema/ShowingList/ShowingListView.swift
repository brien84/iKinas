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
            LazyVStack(spacing: .zero) {
                ForEachStore(
                    store.scope(state: \.showingItems, action: ShowingList.Action.showingItem(id:action:))
                ) {
                    ShowingItemView(store: $0)
                        .padding(.horizontal)

                    Divider()
                        .padding()
                }
            }
        }
    }
}

// MARK: - Previews

struct ShowingListView_Previews: PreviewProvider {
    static let movie = Movie(showings: Array(repeating: Showing(), count: 16))
    static let store = Store(initialState: ShowingList.State(showings: movie.showings), reducer: ShowingList())

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

private extension ShowingList.State {
    init(showings: [Showing]) {
        self.showingItems = IdentifiedArray(uniqueElements: showings.map { ShowingItem.State(id: UUID(), showing: $0) })
    }
}
