//
//  Extension+AnyTransition.swift
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

enum ControlledTransition {
    case blur
    case blurryOffset
    case blurryScale(anchor: UnitPoint)
    case opacity
    case scale
}

extension View {
    @ViewBuilder
    func transition(_ transition: ControlledTransition, isActive: Bool) -> some View {
        switch transition {
        case .blur:
            blur(radius: isActive ? 6 : 0)

        case .blurryOffset:
            blur(radius: isActive ? 6 : 0)
                .offset(x: isActive ? 4 : 0)

        case .blurryScale(let anchor):
            if anchor == .leading {
                blur(radius: isActive ? 6 : 0)
                    .scaleEffect(x: isActive ? 0.98 : 1, anchor: anchor)
            } else {
                blur(radius: isActive ? 6 : 0)
                    .scaleEffect(y: isActive ? 0.98 : 1, anchor: anchor)
            }

        case .opacity:
            opacity(isActive ? 0 : 1)

        case .scale:
            scaleEffect(isActive ? 0.75 : 1)
        }
    }
}
