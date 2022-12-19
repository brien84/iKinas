//
//  ScheduleView.swift
//  Cinema
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

final class ScheduleViewHost: UIHostingController<ScheduleView> {
    let store: StoreOf<Schedule>

    required init?(coder aDecoder: NSCoder) {
        let store = Store(initialState: Schedule.State(), reducer: Schedule())
        self.store = store

        super.init(
            coder: aDecoder,
            rootView: ScheduleView(store: store)
        )
    }
}

struct ScheduleView: View {
    let store: StoreOf<Schedule>

    var body: some View {
        WithViewStore(store) { _ in
            ZStack {
                Color.primaryBackground

            }
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
