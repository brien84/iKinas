//
//  Featured.swift
//  Cinema
//
//  Created by Marius on 2023-10-29.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct Featured: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        let label: String
        var networkImage: NetworkImage.State
        let originalTitle: String
        let title: String
    }

    enum Action: Equatable {
        case didSelect
        case networkImage(NetworkImage.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.networkImage, action: /Action.networkImage) {
            NetworkImage()
        }

        Reduce { _, action in
            switch action {
            case .didSelect:
                return .none
            case .networkImage:
                return .none
            }
        }
    }
}
