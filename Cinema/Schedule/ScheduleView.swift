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

    @State private var headerFrame: CGRect = CGRect()
    @State private var viewFrame: CGRect = CGRect()

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: .zero) {
                        HeaderView(store: store)
                              .background(FrameGetter(frame: $headerFrame))
                              .id(Self.scrollToTopID)

                        if !viewStore.movies.isEmpty {
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
                            EmptyErrorView(
                                title: viewStore.isFiltering ? "seansų nėra" : "nieko nerodo",
                                subtitle: viewStore.isFiltering ? "pakeiskite laiką" : "pasirinkite kitą dieną"
                            )
                            .frame(
                                width: viewFrame.width,
                                height: viewFrame.height - headerFrame.height
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

private struct FilterView: View {
    let store: StoreOf<Schedule>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                DatePicker(
                    "Enter start time.",
                    selection: viewStore.binding(\.filter.$startTime).animation(),
                    displayedComponents: .hourAndMinute
                )

                Text("-")
                    .foregroundColor(.primaryElement)

                DatePicker(
                    "Enter end time.",
                    selection: viewStore.binding(\.filter.$endTime).animation(),
                    displayedComponents: .hourAndMinute
                )
            }
            .accentColor(.tertiaryElement)
            .colorScheme(.dark)
            .frame(maxWidth: .infinity, alignment: .leading)
            .labelsHidden()
        }
    }
}

private struct HeaderView: View {
    let store: StoreOf<Schedule>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: Self.verticalSpacing) {
                DateLabel(date: viewStore.selectedDate)
                    .transitionDateLabel(viewStore.isTransitioning)

                HStack {
                    if viewStore.isFiltering {
                        ZStack {
                            DateLabel(date: viewStore.selectedDate)
                                .labelStyle(.large)
                                .opacity(.zero)

                            FilterView(store: store)
                                .transitionDateLabel(viewStore.isTransitioning)
                        }
                        .transition(.move(edge: .leading))
                    } else {
                        DateLabel(date: viewStore.selectedDate)
                            .labelStyle(.large)
                            .transitionDateLabel(viewStore.isTransitioning)
                            .transition(.move(edge: .leading))
                    }

                    Spacer()

                    Button {
                        viewStore.send(.toggleFiltering, animation: .easeInOut)
                    } label: {
                        Image(systemName: "stopwatch")
                            .font(.title2)
                            .foregroundColor(viewStore.isFiltering ? .tertiaryElement : .primaryElement)
                    }
                }
            }
            .padding([.horizontal, .top])
            .padding(.bottom, Self.bottomPadding)

            Divider()
                .padding(.bottom, Self.bottomPadding)
        }
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

private extension HeaderView {
    static let bottomPadding: CGFloat = 8
    static let verticalSpacing: CGFloat = 8
}

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
    static let showings: [Showing.State] = {
        stride(from: 1, to: 20, by: 1).map { index in
            iKinas.Previews.createShowing(
                date: Date(timeIntervalSinceNow: Double(3600 * index)),
                is3D: index % 2 == 0,
                originalTitle: String(repeating: index % 2 == 0 ? "Title" : "OriginalTitle", count: index),
                title: String(repeating: "Title", count: index)
            )
        }
    }()

    static let store = Store(
        initialState: Schedule.State(datasource: showings.convertToIdentifiedArray()),
        reducer: Schedule()
    )

    static var previews: some View {
        ScheduleView(store: store)
            .background(Color.primaryBackground.ignoresSafeArea())
            .environment(\.locale, .init(identifier: "lt"))
            .preferredColorScheme(.dark)
            .onAppear {
                ViewStore(store).send(.filterDatasource)
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
