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

        var movieList = MovieList.State()
        var showingList = ShowingList.State()
    }

    enum Action: Equatable {
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

            case .settingsButtonDidTap:
                return .none

            case .movieList:
                return .none

            case .showingList:
                return .none
            }
        }
    }
}
