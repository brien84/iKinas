//
//  LiveImageClient.swift
//  Cinema
//
//  Created by Marius on 2023-10-07.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

extension ImageClient: DependencyKey {
    static let liveValue = Self(
        fetch: { url in
            if let image = Self.cache.object(forKey: url as NSURL) {
                return EffectPublisher(value: image)
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
}
