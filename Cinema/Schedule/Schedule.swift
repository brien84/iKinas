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

        var datasource: IdentifiedArrayOf<Showing.State> = []
        var movies: IdentifiedArrayOf<Showing.State> = []
        var showings: IdentifiedArrayOf<Showing.State> = []
    }

    enum Action: Equatable {
        case filterDatasource
        case movie(id: Showing.State.ID, action: Showing.Action)
        case showing(id: Showing.State.ID, action: Showing.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .movie(id: let id, action: .networkImage(.imageClient(.success))):
                guard let networkImage = state.movies[id: id]?.networkImage else { return .none }
                state.datasource[id: id]?.networkImage = networkImage
                return .none

            case .movie:
                return .none

            case .showing(id: let id, action: .networkImage(.imageClient(.success))):
                guard let networkImage = state.showings[id: id]?.networkImage else { return .none }
                state.datasource[id: id]?.networkImage = networkImage
                return .none

            case .showing:
                return .none

            case .filterDatasource:
                state.showings = state.datasource.filter(by: state.selectedDate)
                state.showings.sort(by: .date)
                let uniqueTitles = state.showings.getUniqueTitles()
                state.movies = state.datasource.filterFirstOccurrencesOf(titles: uniqueTitles)
                state.movies.sort(by: .title)
                return .none

            }
        }
        .forEach(\.movies, action: /Action.movie(id:action:)) {
            Showing()
        }
        .forEach(\.showings, action: /Action.showing(id:action:)) {
            Showing()
        }
    }
}
