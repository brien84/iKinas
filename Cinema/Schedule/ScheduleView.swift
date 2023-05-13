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

    @State private var backgroundFrame: CGRect = CGRect()
    @State private var dateFrame: CGRect = CGRect()

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground
                    .background(FrameGetter(frame: $backgroundFrame))

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: .zero) {
                            VStack(spacing: .zero) {
                                SmallDateLabel(date: viewStore.selectedDate)
                                    .transitionDateLabel(viewStore.isTransitioning)

                                LargeDateLabel(date: viewStore.selectedDate)
                                    .padding(.horizontal)
                                    .padding(.vertical, Self.verticalPadding)
                                    .transitionDateLabel(viewStore.isTransitioning)
                            }
                            .id(Self.scrollToTopID)
                            .background(FrameGetter(frame: $dateFrame))

                            Divider()

                            ZStack {
                                VStack {
                                    SectionLabel(text: "Filmai")
                                        .padding(.top, Self.verticalPadding)
                                        .transitionSectionLabel(viewStore.isTransitioning)

                                    MovieListView(store: store)
                                        .frame(height: backgroundFrame.width * Self.heightToWidthRatio)
                                        .transitionMovieListView(viewStore.isTransitioning)

                                    SectionLabel(text: "Seansai")
                                        .transitionSectionLabel(viewStore.isTransitioning)

                                    ShowingListView(store: store)
                                        .transitionShowingListView(viewStore.isTransitioning)
                                }

                                if viewStore.movieItems.isEmpty {
                                    EmptyErrorView(title: "nieko nerodo", subtitle: "pasirinkite kitą dieną")
                                        .frame(
                                            width: backgroundFrame.width,
                                            height: backgroundFrame.height - dateFrame.height
                                        )
                                        .transitionalBlur(viewStore.isTransitioning)
                                }
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
        }
    }
}

private struct LargeDateLabel: View {
    let date: Date

    var body: some View {
        Text(date.toString(.dayOfWeek))
            .font(.largeTitle.bold())
            .foregroundColor(.primaryElement)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SmallDateLabel: View {
    let date: Date

    var body: some View {
        Text(date.toString(.monthAndDay))
            .textCase(.uppercase)
            .font(.caption.bold())
            .foregroundColor(.secondaryElement)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.top, .horizontal])
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
    static let movie = Movie(showings: Array(repeating: Showing(), count: 15))

    static let showingItems = {
        IdentifiedArray(uniqueElements: movie.showings.map {
            ShowingItem.State(id: UUID(), showing: $0)
        })
    }()

    static let store = Store(
        initialState: Schedule.State(
            movieItems: [MovieItem.State(id: UUID(), movie: movie)],
            showingItems: showingItems
        ),
        reducer: Schedule()
    )

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ScheduleView(store: store)
                .preferredColorScheme(.dark)
        }
    }
}
