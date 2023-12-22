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
        var isFetching = false
        var image: UIImage?
        var url: URL?
        let defaultImage: UIImage?

        init(url: URL?, defaultImage: UIImage? = UIImage(named: "posterDefault")) {
            self.url = url
            self.defaultImage = defaultImage
        }
    }

    enum Action: Equatable {
        case fetch
        case imageClient(Result<UIImage, ImageClient.Failure>)
    }

    @Dependency(\.imageClient) var imageClient
    @Dependency(\.mainQueue) var mainQueue

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetch:
            if let url = state.url {
                state.isFetching = true
                return imageClient.fetch(url)
                    .receive(on: mainQueue)
                    .catchToEffect(Action.imageClient)
            } else {
                state.image = state.defaultImage
                return .none
            }

        case .imageClient(let result):
            state.isFetching = false
            switch result {
            case .success(let image):
                state.image = image
            case .failure:
                state.image = state.defaultImage
            }
            return .none
        }
    }
}
