//
//  Extension+View.swift
//  Cinema
//
//  Created by Marius on 2023-10-11.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

enum ControlledTransition {
    case blur
    case blurryOffset
    case blurryScale(anchor: UnitPoint)
    case opacity
    case scale
}

extension View {
    /// Controls the transition of a `View` based on a feature state.
    ///
    /// - Parameters:
    ///   - viewState: The state that drives the view's appearance. This state will be modified when `featureState` changes.
    ///   - featureState: The state that triggers the transition. When this state changes, `viewState` will be updated to reflect the new value.
    ///
    /// ```
    /// struct MyView: View {
    ///     @State private var isTransitioning = false
    ///
    ///     var body: some View {
    ///         WithViewStore(store) { viewStore in
    ///             FooView()
    ///                 .controlTransition(
    ///                     $with: $isTransitioning,
    ///                     when: viewStore.isTransitioning
    ///                 )
    ///         }
    ///     }
    /// }
    /// ```
    func controlTransition(@Binding with viewState: Bool, when featureState: Bool) -> some View {
        self.onChange(of: featureState) { newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewState = newValue
                }
            }
    }

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

struct ScrollToTop {
    static let id: String = "upandaway"
    let proxy: ScrollViewProxy
    let anchor: UnitPoint?

    init(proxy: ScrollViewProxy, anchor: UnitPoint? = nil) {
        self.anchor = anchor
        self.proxy = proxy
    }
}

extension View {
    func scrollTo(_ top: ScrollToTop, when value: Bool) -> some View {
        self.onChange(of: value) { newValue in
            guard newValue else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                top.proxy.scrollTo(ScrollToTop.id, anchor: top.anchor)
            }
        }
    }
}
