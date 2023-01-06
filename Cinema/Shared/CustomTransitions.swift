//
//  CustomTransitions.swift
//  Cinema
//
//  Created by Marius on 2023-01-01.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

private struct TrailingSlideIn: ViewModifier {
    var isActive: Bool

    func body(content: Content) -> some View {
        content
            .blur(radius: isActive ? 10 : 00)
            .offset(x: isActive ? 500 : 0, y: 0)
            .opacity(isActive ? 0.7 : 1)
    }
}

private struct VerticalScaleAndOpacity: ViewModifier {
    private var amount: CGFloat

    init(_ amount: CGFloat) {
        self.amount = amount
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(y: amount, anchor: .top)
            .opacity(amount)
    }
}

extension AnyTransition {
    static var trailingSlideIn: AnyTransition {
        .modifier(
            active: TrailingSlideIn(isActive: true),
            identity: TrailingSlideIn(isActive: false)
        )
    }

    static var verticalScaleAndOpacity: AnyTransition {
        .modifier(
            active: VerticalScaleAndOpacity(0.01),
            identity: VerticalScaleAndOpacity(1)
        )
    }
}
