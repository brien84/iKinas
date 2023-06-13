//
//  ScheduleItem.swift
//  Cinema
//
//  Created by Marius on 2023-06-12.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct ScheduleItem: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID { showing.id }
        let showing: Showing
        let movie: Movie
        var networkImage: NetworkImage.State

        init?(showing: Showing) {
            self.showing = showing
            guard let movie = showing.parentMovie else { return nil }
            self.movie = movie
            self.networkImage = NetworkImage.State(url: movie.poster)
        }
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
