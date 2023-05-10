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
        var networkImage: NetworkImage.State

        init(id: UUID, showing: Showing) {
            self.id = id
            self.showing = showing
            self.networkImage = NetworkImage.State(url: showing.parentMovie?.poster)
        }
    }

    enum Action: Equatable {
        case didSelectShowing(Showing)
        case networkImage(NetworkImage.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.networkImage, action: /Action.networkImage) {
            NetworkImage()
        }

        Reduce { _, action in
            switch action {
            case .didSelectShowing:
                return .none
            case .networkImage:
                return .none
            }
        }
    }

}
