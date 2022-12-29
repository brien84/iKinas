//
//  MovieDetail.swift
//  Cinema
//
//  Created by Marius on 2022-12-29.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieDetail: ReducerProtocol {

    struct State: Equatable {
        var titleViewOverlapPercentage: CGFloat = 0
    }

    enum Action: Equatable {
        case updateTitleViewOverlap(percentage: CGFloat)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateTitleViewOverlap(percentage: let percentage):
                state.titleViewOverlapPercentage = percentage
                return .none
            }
        }
    }

}
