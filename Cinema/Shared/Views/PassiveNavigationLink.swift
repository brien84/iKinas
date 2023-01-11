//
//  PassiveNavigationLink.swift
//  Cinema
//
//  Created by Marius on 2023-01-11.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

/// A NavigationLink that is not visible and cannot be
/// interacted with, but whose destination view can be
/// navigated to by using the `isActive` binding.
struct PassiveNavigationLink<Destination>: View where Destination: View {
    let isActive: Binding<Bool>
    let destination: () -> Destination

    var body: some View {
        NavigationLink(
            isActive: isActive,
            destination: {
                destination()
            },
            label: {
                EmptyView()
            }
        )
        .buttonStyle(.plain)
        .disabled(true)
        .hidden()
    }
}
