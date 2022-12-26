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

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            SmallDateLabel(date: viewStore.date)
                                .padding([.top, .horizontal])
                                .scaleEffect(viewStore.isTransitioning ? 0.75 : 1)
                                .id("top")

                            HStack {
                                LargeDateLabel(date: viewStore.date)
                                    .scaleEffect(viewStore.isTransitioning ? 0.75 : 1)

                                SettingsButton {
                                    viewStore.send(.settingsButtonDidTap)
                                }.hidden(!Calendar.current.isDateInToday(viewStore.date))
                            }.padding(.horizontal)

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

struct ScheduleView_Previews: PreviewProvider {
    static let store = Store(initialState: Schedule.State(), reducer: Schedule())

    static var previews: some View {
        ScheduleView(store: store)
            .preferredColorScheme(.dark)
    }
}
