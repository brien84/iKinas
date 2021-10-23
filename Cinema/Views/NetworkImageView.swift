//
//  NetworkImageView.swift
//  Cinema
//
//  Created by Marius on 17/10/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import UIKit

/// View for downloading and displaying images.
/// When `url` property is set, `NetworkImageView` checks if image is in cache,
/// then either displays image from cache or downloads the image.
final class NetworkImageView: UIImageView {
    private static let cache = NSCache<NSURL, UIImage>()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        indicator.hidesWhenStopped = true

        indicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
        indicator.color = .primaryElement

        indicator.autoresizingMask = [
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleTopMargin,
            .flexibleBottomMargin
        ]

        addSubview(indicator)

        return indicator
    }()

    override var image: UIImage? {
        didSet {
            image == nil ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }

    var url: URL? {
        didSet {
            loadImage()
        }
    }

    private func loadImage() {
        self.image = nil

        guard let url = url else {
            set(.defaultImage)
            return
        }

        // If image data is found in cache.
        if let image = NetworkImageView.cache.object(forKey: url as NSURL) {
            if url == self.url {
                set(image)
            }
        } else {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let responseData = data, let image = UIImage(data: responseData), error == nil
                else {
                    self?.set(.defaultImage)
                    return
                }

                NetworkImageView.cache.setObject(image, forKey: url as NSURL)

                if url == self?.url {
                    self?.set(image)
                }
            }.resume()
        }
    }

    private func set(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.image = image
        }
    }
}

private extension UIImage {
    static let defaultImage = UIImage(named: "defaultPoster")!
}
