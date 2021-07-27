//
//  DateViewCell.swift
//  Cinema
//
//  Created by Marius on 2020-08-06.
//  Copyright © 2020 Marius. All rights reserved.
//

import UIKit

final class DateViewCell: UITableViewCell {
    @IBOutlet weak var poster: NetworkImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var originalTitle: UILabel!
    @IBOutlet weak var venueImage: VenueImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet private var hide3DIcon: NSLayoutConstraint!

    var is3D = false {
        didSet {
            hide3DIcon.isActive = !is3D
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        originalTitle.font = UIFont.preferredItalicFont(forTextStyle: .subheadline)
    }
}
