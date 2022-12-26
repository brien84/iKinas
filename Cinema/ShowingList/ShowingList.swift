//
//  ShowingList.swift
//  Cinema
//
//  Created by Marius on 2022-12-18.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct ShowingList: ReducerProtocol {

    struct State: Equatable {
        var showingItems: IdentifiedArrayOf<ShowingItem.State> = []
    }

    enum Action: Equatable {
        case showingItem(id: ShowingItem.State.ID, action: ShowingItem.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .showingItem:
                return .none
            }
        }
        .forEach(\.showingItems, action: /Action.showingItem(id:action:)) {
            ShowingItem()
        }
    }

}
