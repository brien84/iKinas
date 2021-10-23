//
//  ShowingsViewDateCell.swift
//  Cinema
//
//  Created by Marius on 2021-01-23.
//  Copyright © 2021 Marius. All rights reserved.
//

import UIKit

final class ShowingsViewDateCell: UICollectionViewCell {
    @IBOutlet weak var date: UILabel!

    var isLabelHighlighted = false {
        didSet {
            date.textColor = isLabelHighlighted ? .tertiaryElement : .primaryElement
        }
    }
}
