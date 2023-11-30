//
//  SimilarShowingsList.swift
//  Cinema
//
//  Created by Marius on 2023-11-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SimilarShowingsList: View {
    let store: StoreOf<ShowingInfo>

    var body: some View {
        WithViewStore(store) { _ in
            ScrollView(.horizontal, showsIndicators: false) {

            }
        }
    }
}
