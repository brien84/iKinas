//
//  Extensions.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import SwiftUI
import UIKit

extension UINavigationBar {
    func setBackgroundImage(color: UIColor, alpha: CGFloat = 1.0) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        // If `alpha` is equal or higher than 1.0 `UINavigationBar`
        // will apply a system-defined alpha value.
        let alpha = alpha >= 0.99 ? 0.99 : alpha
        let color = color.withAlphaComponent(alpha)

        // `UINavigationBar` will size the image to fill.
        appearance.backgroundImage = color.image(size: CGSize(width: 1, height: 1))

        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
    }
}

extension View {
    /// Dinamically hides and disables view.
    ///
    /// Since iOS15 the behaviour of `XCUIElement` `isHittable` property
    /// has changed in a way that it no longer returns true if `View` opacity is zero.
    /// As a workaround this function hides and also disables the `View`
    /// therefore we can now assert on `XCUIElement` `isEnabled` property.
    func hidden(_ hidden: Bool) -> some View {
        opacity(hidden ? 0 : 1).disabled(hidden)
    }
}
