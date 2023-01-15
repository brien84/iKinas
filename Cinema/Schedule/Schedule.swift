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
    struct Datasource: Equatable {
        var date: Date = Date()
        var movies: [Movie] = []
    }

    struct State: Equatable {
        var datasource: Datasource = Datasource() {
            didSet {
                didUpdateDatasource = true
            }
        }

        var didUpdateDatasource = false
        var movieItems: IdentifiedArrayOf<MovieItem.State> = []
        var showingItems: IdentifiedArrayOf<ShowingItem.State> = []
        var selectedDate = Date()
    }

    enum Action: Equatable {
        case applyDatasource
        case movieItem(id: MovieItem.State.ID, action: MovieItem.Action)
        case showingItem(id: ShowingItem.State.ID, action: ShowingItem.Action)
        case settingsButtonDidTap
        case transitionDidEnd
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .applyDatasource:
                state.selectedDate = state.datasource.date
                state.movieItems = getMovieItems(from: state.datasource)
                state.showingItems = getShowingItems(from: state.datasource)
                return .none

            case .movieItem:
                return .none

            case .showingItem:
                return .none

            case .settingsButtonDidTap:
                return .none

            case .transitionDidEnd:
                state.didUpdateDatasource = false
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

    private func getMovieItems(from datasource: Datasource) -> IdentifiedArrayOf<MovieItem.State> {
        let showings = datasource.movies.flatMap { movie in
            movie.showings.filter { $0.isShown(on: datasource.date) }
        }

        let parentMovies = Array(Set(showings.compactMap { $0.parentMovie })).sorted()
        let movieItems = parentMovies.map { MovieItem.State(id: uuid(), movie: $0) }

        return IdentifiedArray(uniqueElements: movieItems)
    }

    private func getShowingItems(from datasource: Datasource) -> IdentifiedArrayOf<ShowingItem.State> {
        let showings = datasource.movies.flatMap { movie in
            movie.showings.filter { $0.isShown(on: datasource.date) }
        }.sorted()

        let showingItems = showings.map { ShowingItem.State(id: uuid(), showing: $0) }

        return IdentifiedArray(uniqueElements: showingItems)
    }
}
