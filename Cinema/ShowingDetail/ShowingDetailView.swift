//
//  DetailShowingsView.swift
//  Cinema
//
//  Created by Marius on 2022-12-31.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ShowingDetailView: View {
    let store: StoreOf<ShowingDetail>

    var body: some View {
        WithViewStore(store) { viewStore in
            Text("ShowingDetail")
        }
    }
}
