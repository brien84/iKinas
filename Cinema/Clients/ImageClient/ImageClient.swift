//
//  ImageClient.swift
//  Cinema
//
//  Created by Marius on 2022-12-18.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ImageClient {
    static let cache = NSCache<NSURL, UIImage>()
    var fetch: (URL) -> EffectPublisher<UIImage, Failure>

    struct Failure: Error, Equatable { }
}

extension ImageClient: TestDependencyKey {
    static let previewValue = Self(
        fetch: { _ -> EffectPublisher<UIImage, ImageClient.Failure> in
            EffectPublisher(value: UIImage(named: "posterPreview")!)
                .delay(for: .seconds(1), scheduler: RunLoop.main)
                .eraseToEffect()
        }
    )

    static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch")
    )
}

extension DependencyValues {
    var imageClient: ImageClient {
        get { self[ImageClient.self] }
        set { self[ImageClient.self] = newValue }
    }
}
