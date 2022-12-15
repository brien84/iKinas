//
//  DateSelectorView.swift
//  Cinema
//
//  Created by Marius on 2022-12-15.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct DateSelectorView: View {
    let store: StoreOf<DateSelector>

    var body: some View {
        WithViewStore(store) { _ in
            ZStack {

            }
        }
    }
}

// MARK: - Previews

struct DateSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green

            DateSelectorView(store: Store(initialState: DateSelector.State(), reducer: DateSelector()))
                .preferredColorScheme(.dark)
        }

    }
}
