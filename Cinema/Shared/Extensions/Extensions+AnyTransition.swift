//
//  Extensions+AnyTransition.swift
//  Cinema
//
//  Created by Marius on 2023-01-18.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

extension AnyTransition {
    static var verticalScaleAndOpacity: AnyTransition {
        .modifier(
            active: VerticalScaleAndOpacity(0.01),
            identity: VerticalScaleAndOpacity(1)
        )
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
