//
//  ScheduleView.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ScheduleView: View {
    let store: StoreOf<Schedule>

    @State private var dateFrame: CGRect = CGRect()
    @State private var viewFrame: CGRect = CGRect()

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: .zero) {
                        VStack(spacing: .zero) {
                            SmallDateLabel(date: viewStore.selectedDate)
                                .transitionDateLabel(viewStore.isTransitioning)

                            LargeDateLabel(date: viewStore.selectedDate)
                                .transitionDateLabel(viewStore.isTransitioning)
                                .padding(.top, Self.verticalPadding)

                            Divider()
                                .padding(.vertical, Self.verticalPadding)
                        }
                        .id(Self.scrollToTopID)
                        .padding(.top)
                        .background(FrameGetter(frame: $dateFrame))

                        if !viewStore.movieItems.isEmpty {
                            VStack {
                                SectionLabel(text: "Filmai")
                                    .transitionSectionLabel(viewStore.isTransitioning)

                                MovieListView(store: store)
                                    .frame(height: viewFrame.width * Self.heightToWidthRatio)
                                    .transitionMovieListView(viewStore.isTransitioning)

                                SectionLabel(text: "Seansai")
                                    .transitionSectionLabel(viewStore.isTransitioning)

                                ShowingListView(store: store)
                                    .transitionShowingListView(viewStore.isTransitioning)
                            }
                        } else {
                            EmptyErrorView(title: "nieko nerodo", subtitle: "pasirinkite kitą dieną")
                                .frame(
                                    width: viewFrame.width,
                                    height: viewFrame.height - dateFrame.height
                                )
                                .transitionalBlur(viewStore.isTransitioning)
                        }
                    }
                }
                .transitionScheduleView(viewStore.isTransitioning)
                .onChange(of: viewStore.isTransitioning) { newValue in
                    guard newValue else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Self.scrollToTopDelay) {
                        scrollProxy.scrollTo(Self.scrollToTopID)
                    }
                }
            }
        }
        .background(FrameGetter(frame: $viewFrame))
    }
}

private struct LargeDateLabel: View {
    let date: Date

    var body: some View {
        Text(date.toString(.dayOfWeek))
            .font(.largeTitle.bold())
            .foregroundColor(.primaryElement)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

private struct SmallDateLabel: View {
    let date: Date

    var body: some View {
        Text(date.toString(.monthAndDay))
            .font(.caption.bold())
            .foregroundColor(.secondaryElement)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

private struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.title.bold())
            .foregroundColor(.primaryElement)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

// MARK: - Constants

private extension ScheduleView {
    static let heightToWidthRatio: CGFloat = 0.96
    static let scrollToTopDelay: TimeInterval = 0.3
    static let scrollToTopID: String = "upandaway"
    static let verticalPadding: CGFloat = 8
}

// MARK: - Transitions

private extension View {
    func transitionalBlur(_ isTransitioning: Bool) -> some View {
        blur(radius: isTransitioning ? 6 : 0)
    }

    func transitionDateLabel(_ isTransitioning: Bool) -> some View {
        scaleEffect(isTransitioning ? 0.75 : 1)
    }

    func transitionMovieListView(_ isTransitioning: Bool) -> some View {
        transitionalBlur(isTransitioning)
            .scaleEffect(y: isTransitioning ? 0.98 : 1, anchor: .center)
            .offset(y: isTransitioning ? -5 : 0 )
    }

    func transitionScheduleView(_ isTransitioning: Bool) -> some View {
        opacity(isTransitioning ? 0 : 1)
    }

    func transitionSectionLabel(_ isTransitioning: Bool) -> some View {
        transitionalBlur(isTransitioning)
            .offset(x: isTransitioning ? 4 : 0)
    }

    func transitionShowingListView(_ isTransitioning: Bool) -> some View {
        transitionalBlur(isTransitioning)
            .scaleEffect(x: isTransitioning ? 0.98 : 1, anchor: .leading)
    }
}

// MARK: - Previews

struct ScheduleView_Previews: PreviewProvider {
    static let showings: [Showing] = {
        stride(from: 1, to: 20, by: 1).map { index in
            Showing(
                date: Date(timeIntervalSinceNow: 1),
                is3D: index % 2 == 0,
                originalTitle: String(repeating: index % 2 == 0 ? "Title" : "OriginalTitle", count: index),
                title: String(repeating: "Title", count: index)
            )
        }
    }()

    static let items = {
        IdentifiedArray(uniqueElements: showings.compactMap { ScheduleItem.State(showing: $0) })
    }()

    static let store = Store(
        initialState: Schedule.State(items: items),
        reducer: Schedule()
    )

    static var previews: some View {
        ScheduleView(store: store)
            .background(Color.primaryBackground.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .onAppear {
                ViewStore(store).send(.filterItems)
            }
    }
}

struct EmptyScheduleView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Schedule.State(),
        reducer: Schedule()
    )

    static var previews: some View {
        ScheduleView(store: store)
            .background(Color.primaryBackground.ignoresSafeArea())
            .preferredColorScheme(.dark)
    }
}
