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
                                .padding([.top, .horizontal], 8)

                            HStack {
                                LargeDateLabel(date: viewStore.date)

                                SettingsButton {
                                    viewStore.send(.settingsButtonDidTap)
                                }.hidden(!Calendar.current.isDateInToday(viewStore.date))
                            }

                            Divider()

                            ZStack {
                                VStack {
                                    SectionLabel(text: "Filmai")
                                        .padding(.horizontal, 8)

                                    MovieListView(store: store.scope(
                                        state: \.movieList,
                                        action: Schedule.Action.movieList
                                    ))
                                    .frame(height: 320)

                                    SectionLabel(text: "Seansai")
                                        .padding(.horizontal, 8)

                                    ShowingListView(store: store.scope(
                                        state: \.showingList,
                                        action: Schedule.Action.showingList
                                    ))
                                }
                            }
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
        }.padding(.horizontal, 8)
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static let store = Store(initialState: Schedule.State(), reducer: Schedule())

    static var previews: some View {
        ScheduleView(store: store)
            .preferredColorScheme(.dark)
    }
}
