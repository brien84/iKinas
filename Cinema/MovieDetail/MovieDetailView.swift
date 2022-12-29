//
//  MovieDetailView.swift
//  Cinema
//
//  Created by Marius on 2022-12-29.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieDetailView: View {
    let store: StoreOf<MovieDetail>

    @State private var posterFrame: CGRect = CGRect()
    @State private var titleViewFrame: CGRect = CGRect()
    @State private var safeArea: EdgeInsets = EdgeInsets()
    @State private var posterOverlap: CGFloat = 0

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: .zero) {
                        PosterView()
                            .scaleEffect(posterScale)
                            .offset(y: -posterOffset)
                            .opacity(posterOpacity)
                            .background(FrameGetter(frame: $posterFrame))

                        VStack(spacing: .zero) {
                            TitleView()
                                .opacity(titleViewOpacity)
                                .background(FrameGetter(frame: $titleViewFrame))

                            BodyView()
                        }
                        .offset(y: -posterOverlap)
                    }
                }
                .padding(.bottom, -posterOverlap)
            }
            .ignoresSafeArea(edges: .top)
            .background(SafeAreaGetter(insets: $safeArea))
            .onChange(of: titleViewFrame) { _ in
                let distance = titleViewFrame.minY.distance(to: safeArea.top)

                if distance <= 0 {
                    viewStore.send(.updateTitleViewOverlap(percentage: .zero))
                    return
                }

                let percentage = distance / titleViewFrame.height

                if percentage > 1 {
                    viewStore.send(.updateTitleViewOverlap(percentage: 1))
                } else {
                    viewStore.send(.updateTitleViewOverlap(percentage: percentage))
                }
            }
            .onChange(of: titleViewFrame.height) { newValue in
                let height = round(newValue * 1000) / 1000.0
                let overlap = height + posterOverlapConstant

                if overlap != posterOverlap {
                    posterOverlap = overlap
                }
            }
        }
    }
}

extension MovieDetailView {
    // Minimum `PosterView` overlap value.
    private var posterOverlapConstant: CGFloat {
        60
    }

    // When `PosterView` is not overlapped `TitleView` opacity is zero.
    private var titleViewOpacity: CGFloat {
        1 - posterFrame.minY / posterOverlapConstant
    }

    // Scales the `PosterView` when scrolling downwards after the `PosterView` is no longer overlapped.
    private var posterScale: CGFloat {
        if posterFrame.minY > posterOverlapConstant {
            return (posterFrame.height - posterOverlapConstant + posterFrame.minY) / posterFrame.height
        }

        return 1
    }

    // Keeps the `PosterView` stuck to the top of the screen when scrolling downwards.
    private var posterOffset: CGFloat {
        guard posterFrame.minY > .zero else { return .zero }

        if posterFrame.minY < posterOverlapConstant {
            return posterFrame.minY
        }

        if posterFrame.minY > .zero {
            return (posterFrame.minY + posterOverlapConstant) * 0.5
        }

        return .zero
    }

    // When the top edge of the `TitleView` reaches the bottom edge of the navigation bar,
    // the opacity of the `PosterView` is zero.
    private var posterOpacity: CGFloat {
        let totalDistance = posterFrame.height - titleViewFrame.height - safeArea.top - posterOverlapConstant
        let currentDistance = safeArea.top.distance(to: titleViewFrame.minY)
        return currentDistance / totalDistance
    }
}

struct PosterView: View {
    var body: some View {
        Image("posterPreview")
            .resizable()
            .frame(maxWidth: .infinity)
            .aspectRatio(2/3, contentMode: .fit)
    }
}

struct TitleView: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.8)

            VStack {
                Text("Pavadinimas")
                    .font(.title)

                Text("Title")
                    .font(.title2)

                Text("2021 • N-18 • 112 min")
                    .font(.footnote)
            }
            .foregroundColor(.primaryElement)
            .padding()

        }
    }
}

struct BodyView: View {
    var body: some View {
        ZStack {
            Color.orange

            Text(String(repeating: "X", count: 3000))
        }
    }
}

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
