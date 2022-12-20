//
//  MainView.swift
//  Cinema
//
//  Created by Marius on 2022-12-20.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                VStack(spacing: .zero) {

                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }

}

struct MainView_Previews: PreviewProvider {
    static let store = Store(initialState: Main.State(), reducer: Main())

    static var previews: some View {
        MainView(store: store)
            .preferredColorScheme(.dark)
    }
}
