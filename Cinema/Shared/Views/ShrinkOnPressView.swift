//
//  ShrinkOnPressView.swift
//  Cinema
//
//  Created by Marius on 2023-01-09.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

/// A container view that contracts its subviews when the user performs a long press gesture on it.
struct ShrinkOnPressView<Content: View>: View {
    let content: () -> Content

    @State private var isBeingPressed = false

    var body: some View {
        content()
            .opacity(isBeingPressed ? longPressOpacity : 1)
            .scaleEffect(isBeingPressed ? longPressScaleEffect : 1)
            .onTapGesture { }
            .onLongPressGesture(perform: { }, onPressingChanged: { isPressing in
                withAnimation(longPressAnimation) {
                    isBeingPressed = isPressing
                }
            })
    }
}

private extension ShrinkOnPressView {
    var longPressAnimation: Animation {
        .spring(response: 0.5, dampingFraction: 0.5)
    }

    var longPressOpacity: CGFloat {
        0.95
    }

    var longPressScaleEffect: CGFloat {
        0.95
    }
}
