//
//  Extensions+View.swift
//  Cinema
//
//  Created by Marius on 2023-01-11.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

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
