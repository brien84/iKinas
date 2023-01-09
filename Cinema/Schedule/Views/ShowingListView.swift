//
//  ShowingListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

private extension ShowingListView {
    struct State: Equatable {
        var showingItems: IdentifiedArrayOf<ShowingItem.State> = []
    }

    enum Action: Equatable {
        case showingItem(id: ShowingItem.State.ID, action: ShowingItem.Action)
    }
}

private extension Schedule.State {
    var state: ShowingListView.State {
        .init(showingItems: self.showingItems)
    }
}

private extension ShowingListView.Action {
    var action: Schedule.Action {
        switch self {
        case .showingItem(let id, let action):
            return .showingItem(id: id, action: action)
        }
    }
}

struct ShowingListView: View {
    let store: StoreOf<Schedule>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { _ in
            LazyVStack(spacing: .zero) {
                ForEachStore(
                    store.scope(state: \.showingItems, action: Schedule.Action.showingItem(id:action:))
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
