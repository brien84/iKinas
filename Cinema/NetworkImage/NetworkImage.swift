//
//  NetworkImage.swift
//  Cinema
//
//  Created by Marius on 2022-12-17.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct NetworkImage: ReducerProtocol {

    struct State: Equatable {
        var url: URL
        var image: UIImage?
    }

    enum Action: Equatable {
        case none
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .none:
            return .none
        }
    }

}
