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
            }
            .padding()
        }
        .padding(.horizontal)
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
}

// MARK: - Previews

struct UpcomingListView_Previews: PreviewProvider {
    static let store = Store(
        initialState: HomeFeed.State(),
        reducer: HomeFeed()
    )

    static var previews: some View {
        UpcomingListView(store: store)
    }
}
