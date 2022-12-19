//
//  ImageClient.swift
//  Cinema
//
//  Created by Marius on 2022-12-18.
//  Copyright © 2022 Marius. All rights reserved.
//

import Combine
import ComposableArchitecture
import SwiftUI
import XCTestDynamicOverlay

struct ImageClient {
    private static let cache = NSCache<NSURL, UIImage>()

    var fetch: (URL) -> Effect<UIImage, Failure>

    struct Failure: Error, Equatable { }
}

extension DependencyValues {
    var imageClient: ImageClient {
        get { self[ImageClient.self] }
        set { self[ImageClient.self] = newValue }
    }
}

extension ImageClient: DependencyKey {
    static let liveValue = Self(
        fetch: { url in
            if let image = Self.cache.object(forKey: url as NSURL) {
                return Effect(value: image)
            } else {
                return URLSession.shared.dataTaskPublisher(for: url)
                    .tryMap {
                        guard let image = UIImage(data: $0.data) else {
                            throw Self.Failure()
                        }

                        Self.cache.setObject(image, forKey: url as NSURL)
                        return image
                    }
                    .mapError { _ in
                        Self.Failure()
                    }
                    .eraseToEffect()
            }
        }
    )

    static let previewValue = Self(
        fetch: { _ -> Effect<UIImage, ImageClient.Failure> in
            Effect(value: UIImage(named: "preview")!)
                .delay(for: .seconds(3), scheduler: RunLoop.main)
                .eraseToEffect()
        }
    )

    static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch")
    )
}
