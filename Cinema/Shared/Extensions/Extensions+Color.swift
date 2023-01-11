//
//  Extensions+Color.swift
//  Cinema
//
//  Created by Marius on 2023-01-11.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

extension Color {
    static let primaryElement = Color("primaryElement")
    static let secondaryElement = Color("secondaryElement")
    static let tertiaryElement = Color("tertiaryElement")
    static let primaryBackground = Color("primaryBackground")
    static let secondaryBackground = Color("secondaryBackground")
}

extension UIColor {
    static let primaryElement = UIColor(named: "primaryElement")!
    static let secondaryElement = UIColor(named: "secondaryElement")!
    static let tertiaryElement = UIColor(named: "tertiaryElement")!
    static let primaryBackground = UIColor(named: "primaryBackground")!
    static let secondaryBackground = UIColor(named: "secondaryBackground")!
    static let tertiaryBackground = UIColor(named: "tertiaryBackground")!
}

extension UIColor {
    /// Creates `UIImage` filled with `UIColor`.
    func image(size: CGSize, isEclipse: Bool = false) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { rendererContext in
            let rect = CGRect(origin: .zero, size: size)
            self.setFill()

            if isEclipse {
                rendererContext.cgContext.fillEllipse(in: rect)
            } else {
                rendererContext.fill(rect)
            }
        }
    }
}
