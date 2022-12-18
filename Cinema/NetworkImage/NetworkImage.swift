//
//  NetworkImage.swift
//  Cinema
//
//  Created by Marius on 2022-12-17.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import Foundation

struct NetworkImage: ReducerProtocol {
    static let defaultImage = UIImage(named: "defaultPoster")

    struct State: Equatable {
        var image: UIImage?
        var isFetching = false
        var url: URL
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
            state.isFetching = true
            return imageClient.fetch(state.url)
                .receive(on: mainQueue)
                .catchToEffect(Action.imageClient)

        case .imageClient(let result):
            state.isFetching = false
            switch result {
            case .success(let image):
                state.image = image
            case .failure:
                state.image = Self.defaultImage
            }
            return .none
        }
    }

}
