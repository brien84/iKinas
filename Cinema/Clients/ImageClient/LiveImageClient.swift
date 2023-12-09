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
            guard !CommandLine.isUITesting else { return EffectPublisher(value: UIImage(named: url.absoluteString)!) }
            if let image = Self.cache.object(forKey: url as NSURL) {
                return EffectPublisher(value: image)
            } else {
                return URLSession.shared.dataTaskPublisher(for: url)
                    .tryMap {
                        guard let image = UIImage(data: $0.data) else { throw Self.Failure() }
                        let optimized = image.optimizeSize()
                        Self.cache.setObject(optimized, forKey: url as NSURL)
                        return optimized
                    }
                    .mapError { _ in
                        Self.Failure()
                    }
                    .eraseToEffect()
            }
        }
    )
}

private extension UIImage {
    /// Optimizes `UIImage` to reduce its memory footprint by reducing size of the image while increasing its scale factor.
    func optimizeSize() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0 / self.scale
        let size = CGSize(width: self.size.width / format.scale, height: self.size.height / format.scale)
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
