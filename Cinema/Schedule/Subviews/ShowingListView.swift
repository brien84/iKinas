//
//  ShowingListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ShowingListView: View {
    let store: StoreOf<Schedule>

    var body: some View {
        LazyVStack(spacing: Self.verticalSpacing) {
            ForEachStore(store.scope(
                state: \.showings,
                action: Schedule.Action.showing(id:action:)
            )) {
                ShowingView(store: $0)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, Self.bottomPadding)
    }
}

// MARK: - Constants

private extension ShowingListView {
    static let bottomPadding: CGFloat = 8
    static let verticalSpacing: CGFloat = 8
}
