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
            LazyVStack(spacing: .verticalSpacing) {
                ForEachStore(
                    store.scope(state: \.showingItems, action: ShowingList.Action.showingItem(id:action:))
                ) {
                    ShowingItemView(store: $0)
                        .padding(.horizontal, .horizontalPadding)
                }
            }
        }

    }
}

private extension CGFloat {
    static let horizontalPadding: CGFloat = 8
    static let verticalSpacing: CGFloat = 8
}

struct ShowingListView_Previews: PreviewProvider {
    static let movie = Movie()
    static let showings = Array(repeating: Showing(parentMovie: movie), count: 5)

    static let store = Store(initialState: ShowingList.State(showings: showings), reducer: ShowingList())

    static var previews: some View {
        ShowingListView(store: store)
            .preferredColorScheme(.dark)
    }
}

private extension ShowingList.State {
    init(showings: [Showing]) {
        self.showingItems = IdentifiedArray(uniqueElements: showings.map { ShowingItem.State(id: UUID(), showing: $0) })
    }
}
