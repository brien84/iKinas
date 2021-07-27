//
//  ShowingsViewTimeCell.swift
//  Cinema
//
//  Created by Marius on 2021-01-24.
//  Copyright © 2021 Marius. All rights reserved.
//

import UIKit

final class ShowingsViewTimeCell: UICollectionViewCell {
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var venueImage: VenueImageView!
    @IBOutlet private var hide3DIcon: NSLayoutConstraint!

    var is3D = false {
        didSet {
            hide3DIcon.isActive = !is3D
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderColor = UIColor.secondaryElement.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        hide3DIcon.isActive = !is3D
    }
}
