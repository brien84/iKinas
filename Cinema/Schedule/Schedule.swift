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
        let date: Date
        let movies: [Movie]

        init(date: Date = Date(), movies: [Movie] = []) {
            self.date = date
            self.movies = movies
        }
    }

    struct State: Equatable {
        var datasource: Datasource = Datasource()

        var date: Date {
            datasource.date
        }

        var movies: [Movie] {
            datasource.movies
        }

        var isTransitioning = false
        var requiresScrollToTop = false

        var movieList = MovieList.State()
        var showingList = ShowingList.State()
    }

    enum Action: Equatable {
        case datasourceNeedsUpdate(Datasource)
        case beginTransition(Datasource)
        case updateDatasource(Datasource)
        case endTransition

        case settingsButtonDidTap

        case movieList(action: MovieList.Action)
        case showingList(action: ShowingList.Action)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.showingList, action: /Action.showingList) {
            ShowingList()
        }

        Scope(state: \.movieList, action: /Action.movieList) {
            MovieList()
        }

        Reduce { state, action in
            switch action {

            case .datasourceNeedsUpdate(let datasource):
                return Effect(value: .beginTransition(datasource))
                    .delay(for: .milliseconds(10), scheduler: mainQueue)
                    .eraseToEffect()
                    .animation(.easeInOut(duration: 0.3))

            case .beginTransition(let datasource):
                state.isTransitioning = true
                return Effect(value: .updateDatasource(datasource))
                    .delay(for: .seconds(0.3), scheduler: mainQueue)
                    .eraseToEffect()

            case .updateDatasource(let datasource):
                state.datasource = datasource
                state.requiresScrollToTop = true
                state.movieList.requiresScrollToTop = true
                state.movieList.movieItems = getMovieItems(from: state.datasource)
                state.showingList.showingItems = getShowingItems(from: state.datasource)
                return Effect(value: .endTransition)
                    .delay(for: .milliseconds(10), scheduler: mainQueue)
                    .eraseToEffect()
                    .animation(.easeInOut(duration: 0.4))

            case .endTransition:
                state.requiresScrollToTop = false
                state.movieList.requiresScrollToTop = false
                state.isTransitioning = false
                return .none

            case .settingsButtonDidTap:
                return .none

            case .movieList:
                return .none

            case .showingList:
                return .none
            }
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
