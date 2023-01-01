//
//  GetterViews.swift
//  Cinema
//
//  Created by Marius on 2023-01-01.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

/// Reads and writes the `frame` of a `View` into a binding.
///
/// To use `FrameGetter`, add it to a `View` as a background using the `background` modifier.
/// The `frame` of the surrounding view will be read and stored in the provided property.
///
/// Example:
///
///     struct SomeView: View {
///         @State var frame: CGRect = CGRect()
///
///         var body: some View {
///             VStack {
///                 Text("Hello, World!")
///             }
///             .background(FrameGetter(frame: $frame))
///         }
///     }
struct FrameGetter: View {
    @Binding var frame: CGRect

    var body: some View {
        GeometryReader { proxy in
            self.makeView(proxy: proxy)
        }
    }

    func makeView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            frame = proxy.frame(in: .global)
        }

        return Color.clear
    }
}

/// Reads and writes the `safeAreaInsets` of a `View` into a binding.
///
/// To use `SafeAreaGetter`, add it to a `View` as a background using the `background` modifier.
/// The `safeAreaInsets` of the surrounding view will be read and stored in the provided property.
///
/// Example:
///
///     struct SomeView: View {
///         @State var safeAreaInsets: EdgeInsets = EdgeInsets()
///
///         var body: some View {
///             VStack {
///                 Text("Hello, World!")
///             }
///             .background(SafeAreaGetter(frame: $frame))
///         }
///     }
struct SafeAreaGetter: View {
    @Binding var insets: EdgeInsets

    var body: some View {
        GeometryReader { proxy in
            self.makeView(proxy: proxy)
        }
    }

    func makeView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            insets = proxy.safeAreaInsets
        }

        return Color.clear
    }
}
