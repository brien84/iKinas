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
    }

    enum Action: Equatable {
        case none
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .none:
                return .none
            }
        }
    }

}
