//
//  ShowingItem.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct ShowingItem: ReducerProtocol {

    struct State: Equatable, Identifiable {
        let id: UUID
        let showing: Showing
    }

    enum Action: Equatable {
        case didSelectShowing(Showing)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didSelectShowing:
                return .none
            }
        }
    }

}
