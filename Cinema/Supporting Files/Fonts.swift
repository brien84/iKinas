//
//  Fonts.swift
//  Cinema
//
//  Created by Marius on 2020-09-04.
//  Copyright © 2020 Marius. All rights reserved.
//

import UIKit

enum Fonts: String {
    case dateViewHeader
    case movieViewTitle
    case movieViewOriginalTitle
    case navigationBar
    case notFound

    private var font: UIFont {
        switch self {
        case .dateViewHeader:
            return UIFont(name: "HelveticaNeue-Bold", size: 30)!
        case .movieViewTitle:
            return UIFont(name: "HelveticaNeue-Medium", size: 28)!
        case .movieViewOriginalTitle:
            return UIFont(name: "HelveticaNeue-Light", size: 16)!
        case .navigationBar:
            return UIFont(name: "HelveticaNeue-Medium", size: 17)!
        default:
            return UIFont(name: "BodoniOrnamentsITCTT", size: 50)!
        }
    }

    static func getFont(_ font: Fonts) -> UIFont {
        font.font
    }

    static func getFont(_ identifier: String) -> UIFont {
        if let fonts = Fonts(rawValue: identifier) {
            return fonts.font
        }

        return Fonts.notFound.font
    }
}
