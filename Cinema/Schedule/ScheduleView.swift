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

    @State private var isTransitioning = true

    @State private var headerFrame: CGRect = CGRect()
    @State private var viewFrame: CGRect = CGRect()

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: .zero) {
                        HeaderView(store: store)
                              .background(FrameGetter(frame: $headerFrame))
                              .id(ScrollToTop.id)

                        if !viewStore.movies.isEmpty {
                            VStack {
                                SectionLabel(text: "Filmai")
                                    .transition(.blurryOffset, isActive: isTransitioning)

                                MovieListView(store: store)
                                    .frame(height: viewFrame.width * Self.heightToWidthRatio)
                                    .transition(.blurryScale(anchor: .center), isActive: isTransitioning)

                                SectionLabel(text: "Seansai")
                                    .transition(.blurryOffset, isActive: isTransitioning)

                                ShowingListView(store: store)
                                    .transition(.blurryScale(anchor: .leading), isActive: isTransitioning)
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
                            .transition(.blur, isActive: isTransitioning)
                        }
                    }
                }
                .scrollTo(ScrollToTop(proxy: proxy), when: viewStore.isTransitioning)
                .transition(.opacity, isActive: isTransitioning)
            }
            .controlTransition($with: $isTransitioning, when: viewStore.isTransitioning)
        }
        .background(FrameGetter(frame: $viewFrame))
    }
}

private struct HeaderView: View {
    let store: StoreOf<Schedule>

    @State private var isTransitioning = true

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: Self.verticalSpacing) {
                DateView(date: viewStore.selectedDate)
                    .transition(.scale, isActive: isTransitioning)
                    .padding([.horizontal, .top])

                HStack {
                    if viewStore.isFiltering {
                        ZStack {
                            DateView(date: viewStore.selectedDate)
                                .labelStyle(.large)
                                .opacity(.zero)

                            FilterView(store: store)
                                .transition(.scale, isActive: isTransitioning)
                        }
                        .transition(.move(edge: .leading))
                    } else {
                        DateView(date: viewStore.selectedDate)
                            .labelStyle(.large)
                            .transition(.scale, isActive: isTransitioning)
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
                    .transition(.blur, isActive: isTransitioning)
                }
                .padding(.horizontal)

                Divider()
            }
            .padding(.bottom, Self.bottomPadding)
            .controlTransition($with: $isTransitioning, when: viewStore.isTransitioning)
        }
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
    static let bottomPadding: CGFloat = 10
    static let verticalSpacing: CGFloat = 8
}

private extension ScheduleView {
    static let heightToWidthRatio: CGFloat = 0.8
}

// MARK: - Previews

struct ScheduleView_Previews: PreviewProvider {
    static let showings: [Showing.State] = {
        stride(from: 0, through: 20, by: 1).map { index in
            iKinas.Previews.createShowing(
                date: Date(timeIntervalSinceNow: .hour * TimeInterval(index)),
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
                ViewStore(store).send(.toggleTransition)
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
            .onAppear {
                ViewStore(store).send(.toggleTransition)
            }
    }
}
