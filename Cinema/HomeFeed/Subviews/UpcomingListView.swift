//
//  UpcomingListView.swift
//  Cinema
//
//  Created by Marius on 2023-10-02.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct UpcomingListView: View {
    let store: StoreOf<HomeFeed>

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .fill(Color.secondaryBackground)

            VStack {
                ScheduleButton(store: store)

                VStack(spacing: Self.verticalSpacing) {
                    ForEachStore(store.scope(
                        state: \.upcoming,
                        action: HomeFeed.Action.upcoming(id:action:)
                    )) {
                        ShowingView(store: $0)
                    }
                }
            }
            .padding()
        }
        .padding(.horizontal)
        .accessibilityIdentifier("\(Self.self)")
    }
}

private struct ScheduleButton: View {
    let store: StoreOf<HomeFeed>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button {
                viewStore.send(.scheduleButtonDidTap)
            } label: {
                HStack {
                    Text("Artimiausi")
                        .font(.title2.bold())
                        .foregroundColor(.primaryElement)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.forward")
                        .font(.headline.bold())
                        .foregroundColor(.tertiaryElement)
                }
            }
        }
    }
}

// MARK: - Constants

private extension UpcomingListView {
    static let cornerRadius: CGFloat = 15
    static let verticalSpacing: CGFloat = 8
}

// MARK: - Previews

struct UpcomingListView_Previews: PreviewProvider {
    static let showings: IdentifiedArrayOf<Showing.State> = {
        stride(from: 1, through: 5, by: 1).map { _ in
            iKinas.Previews.createShowing()
        }.convertToIdentifiedArray()
    }()

    static let store = Store(
        initialState: HomeFeed.State(upcoming: showings),
        reducer: HomeFeed()
    )

    static var previews: some View {
        UpcomingListView(store: store)
            .fixedSize(horizontal: false, vertical: true)
    }
}
