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
                        PosterView(store: store)
                            .scaleEffect(posterScale)
                            .offset(y: -posterOffset)
                            .opacity(posterOpacity)
                            .background(FrameGetter(frame: $posterFrame))

                        VStack(spacing: .zero) {
                            TitleView(movie: viewStore.movie)
                                .opacity(titleViewOpacity)
                                .background(FrameGetter(frame: $titleViewFrame))

                            BodyView(store: store)
                        }
                        .offset(y: -posterOverlap)
                    }
                }
                .padding(.bottom, -posterOverlap)
                .disabled(viewStore.showingDetail != nil || viewStore.isScrollDisabled)

                IfLetStore(
                    store.scope(
                        state: \.showingDetail,
                        action: MovieDetail.Action.showingDetail
                    ),
                    then: ShowingDetailView.init(store:)
                )
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

private extension MovieDetailView {
    // Minimum `PosterView` overlap value.
    var posterOverlapConstant: CGFloat {
        60
    }

    // When `PosterView` is not overlapped `TitleView` opacity is zero.
    var titleViewOpacity: CGFloat {
        1 - posterFrame.minY / posterOverlapConstant
    }

    // Scales the `PosterView` when scrolling downwards after the `PosterView` is no longer overlapped.
    var posterScale: CGFloat {
        if posterFrame.minY > posterOverlapConstant {
            return (posterFrame.height - posterOverlapConstant + posterFrame.minY) / posterFrame.height
        }

        return 1
    }

    // Keeps the `PosterView` stuck to the top of the screen when scrolling downwards.
    var posterOffset: CGFloat {
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
    var posterOpacity: CGFloat {
        let totalDistance = posterFrame.height - titleViewFrame.height - safeArea.top - posterOverlapConstant
        let currentDistance = safeArea.top.distance(to: titleViewFrame.minY)
        return currentDistance / totalDistance
    }
}

// MARK: - Previews

struct MovieDetailView_Previews: PreviewProvider {
    static let store = Store(initialState: MovieDetail.State(movie: Movie()), reducer: MovieDetail())

    static var previews: some View {
        MovieDetailView(store: store)
            .preferredColorScheme(.dark)
    }
}
