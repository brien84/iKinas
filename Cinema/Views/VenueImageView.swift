//
//  VenueImageView.swift
//  Cinema
//
//  Created by Marius on 2021-07-26.
//  Copyright © 2021 Marius. All rights reserved.
//

import UIKit

final class VenueImageView: UIImageView {
    var venue: Venue? {
        didSet {
            image = venueImage
        }
    }

    private var venueImage: UIImage {
        switch venue {
        case .cinamon:
            return .cinamon
        case .forum, .forumVingis:
            return .forumGold
        case .forumAkropolis:
            return .forumWhite
        case .multikino:
            return .multikino
        default:
            return UIImage()
        }
    }
}

private extension CGFloat {
    static let padding: CGFloat = 8
}
