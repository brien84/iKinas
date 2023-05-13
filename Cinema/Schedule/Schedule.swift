//
//  Schedule.swift
//  Cinema
//
//  Created by Marius on 2022-12-18.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct Schedule: ReducerProtocol {
    struct State: Equatable {
        var isTransitioning = false
        var movieItems: IdentifiedArrayOf<MovieItem.State> = []
        var showingItems: IdentifiedArrayOf<ShowingItem.State> = []
        var selectedDate = Date()
    }

    enum Action: Equatable {
        case movieItem(id: MovieItem.State.ID, action: MovieItem.Action)
        case showingItem(id: ShowingItem.State.ID, action: ShowingItem.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .movieItem:
                return .none

            case .showingItem:
                return .none
            }
        }
        .forEach(\.movieItems, action: /Action.movieItem(id:action:)) {
            MovieItem()
        }
        .forEach(\.showingItems, action: /Action.showingItem(id:action:)) {
            ShowingItem()
        }
    }
}
