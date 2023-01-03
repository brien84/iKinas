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
                                SmallDateLabel(date: viewStore.date)
                                    .padding([.top, .horizontal])
                                    .scaleEffect(viewStore.isTransitioning ? 0.75 : 1)

                                HStack {
                                    LargeDateLabel(date: viewStore.date)
                                        .scaleEffect(viewStore.isTransitioning ? 0.75 : 1)

                                    SettingsButton {
                                        viewStore.send(.settingsButtonDidTap)
                                    }.hidden(!Calendar.current.isDateInToday(viewStore.date))
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                            .id("top")
                            .background(FrameGetter(frame: $dateFrame))

                            Divider()

                            ZStack {
                                VStack {
                                    SectionLabel(text: "Filmai")
                                        .padding(.horizontal)

                                    MovieListView(store: store.scope(
                                        state: \.movieList,
                                        action: Schedule.Action.movieList
                                    ))
                                    // Instead of using a `GeometryReader` view to retrieve
                                    // the width value of the screen, it is more efficient
                                    // to use the `UIScreen` object, since the view always
                                    // takes up the entire width of the screen.
                                    .frame(height: UIScreen.main.bounds.width * 0.95)
                                    .blur(radius: viewStore.isTransitioning ? 7 : 0)
                                    .scaleEffect(y: viewStore.isTransitioning ? 0.99 : 1, anchor: .center)
                                    .offset(y: viewStore.isTransitioning ? -5 : 0 )

                                    SectionLabel(text: "Seansai")
                                        .padding(.horizontal)

                                    ShowingListView(store: store.scope(
                                        state: \.showingList,
                                        action: Schedule.Action.showingList
                                    ))
                                    .blur(radius: viewStore.isTransitioning ? 7 : 0)
                                    .scaleEffect(x: viewStore.isTransitioning ? 0.98 : 1, anchor: .leading)
                                }.padding(.top, 8)

                                if viewStore.movieList.movieItems.isEmpty {
                                    DatasourceErrorView()
                                        .frame(
                                            width: backgroundFrame.width,
                                            height: backgroundFrame.height - dateFrame.height
                                        )
                                }
                            }
                        }

                    }
                    .opacity(viewStore.isTransitioning ? 0 : 1)
                    .onChange(of: viewStore.requiresScrollToTop) { newValue in
                        if newValue {
                            scrollProxy.scrollTo("top")
                        }
                    }
                }

            }
        }
    }
}

private struct SettingsButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "gearshape")
                .font(.title2)
                .foregroundColor(.primaryElement)
        }
    }
}

// MARK: - Previews

struct ScheduleView_Previews: PreviewProvider {
    static let movie = Movie(showings: Array(repeating: Showing(), count: 15))
    static let movieList = MovieList.State(movies: [movie])
    static let showingList = ShowingList.State(showings: movie.showings)
    static let store = Store(initialState: Schedule.State(movieList: movieList, showingList: showingList), reducer: Schedule())

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ScheduleView(store: store)
                .preferredColorScheme(.dark)
        }
    }
}

private extension MovieList.State {
    init(movies: [Movie]) {
        self.movieItems = IdentifiedArray(uniqueElements: movies.map { MovieItem.State(id: UUID(), movie: $0) })
    }
}

private extension ShowingList.State {
    init(showings: [Showing]) {
        self.showingItems = IdentifiedArray(uniqueElements: showings.map { ShowingItem.State(id: UUID(), showing: $0) })
    }
}
