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
        var selectedDate = Date()

        var items: IdentifiedArrayOf<ScheduleItem.State> = []
        var movieItems: IdentifiedArrayOf<ScheduleItem.State> = []
        var showingItems: IdentifiedArrayOf<ScheduleItem.State> = []
    }

    enum Action: Equatable {
        case filterItems
        case movieItem(id: ScheduleItem.State.ID, action: ScheduleItem.Action)
        case showingItem(id: ScheduleItem.State.ID, action: ScheduleItem.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .movieItem(id: let id, action: .networkImage(.imageClient(.success))):
                guard let networkImage = state.movieItems[id: id]?.networkImage else { return .none }
                state.items[id: id]?.networkImage = networkImage
                return .none

            case .movieItem:
                return .none

            case .showingItem(id: let id, action: .networkImage(.imageClient(.success))):
                guard let networkImage = state.showingItems[id: id]?.networkImage else { return .none }
                state.items[id: id]?.networkImage = networkImage
                return .none

            case .showingItem:
                return .none

            case .filterItems:
                state.showingItems = state.items.filter {
                    $0.showing.isShown(on: state.selectedDate)
                }
                state.showingItems.sort(by: { $0.showing < $1.showing })

                state.movieItems.removeAll()
                for item in state.showingItems where !state.movieItems.contains(where: { $0.showing.title == item.showing.title }) {
                    state.movieItems.append(item)
                }
                state.movieItems.sort(by: { $0.showing.title < $1.showing.title })
                return .none

            }
        }
        .forEach(\.movieItems, action: /Action.movieItem(id:action:)) {
            ScheduleItem()
        }
        .forEach(\.showingItems, action: /Action.showingItem(id:action:)) {
            ScheduleItem()
        }
    }
}
