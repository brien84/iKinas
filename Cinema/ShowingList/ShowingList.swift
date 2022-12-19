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
        var selectedShowing: Showing?
    }

    enum Action: Equatable {
        case didDeselectShowing
        case showingItem(id: ShowingItem.State.ID, action: ShowingItem.Action)
        case update(showings: [Showing])
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .didDeselectShowing:
                state.selectedShowing = nil
                return .none

            case .showingItem(id: _, action: .didSelectShowing(let showing)):
                state.selectedShowing = showing
                return .none

            case .showingItem:
                return .none

            case .update(showings: let showings):
                state.showingItems = IdentifiedArray(uniqueElements: showings.map { ShowingItem.State(id: uuid(), showing: $0) })
                return .none

            }
        }
        .forEach(\.showingItems, action: /Action.showingItem(id:action:)) {
            ShowingItem()
        }
    }

}
