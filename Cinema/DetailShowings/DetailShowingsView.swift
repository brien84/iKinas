//
//  DetailShowingsView.swift
//  Cinema
//
//  Created by Marius on 2022-12-31.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct DetailShowingsView: View {
    let store: StoreOf<DetailShowings>

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                Text("Seansai")
                    .font(.title.bold())
                    .foregroundColor(.primaryElement)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(viewStore.sections) { section in
                    Text(section.date.asString(.monthAndDay))
                        .font(.title3.weight(.semibold))
                        .foregroundColor(viewStore.selectedSection == section ? .tertiaryElement : .secondaryElement)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
    }
}

// MARK: - Previews

struct MovieShowingsView_Previews: PreviewProvider {
    static let showings = [
        Showing(date: Date(timeIntervalSinceNow: 3600)),
        Showing(date: Date(timeIntervalSinceNow: 9000)),
        Showing(date: Date(timeIntervalSinceNow: 90000)),
        Showing(date: Date(timeIntervalSinceNow: 180000))
    ]

    static let store = Store(initialState: DetailShowings.State(movie: Movie(showings: showings)), reducer: DetailShowings())

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            DetailShowingsView(store: store)
        }
        .preferredColorScheme(.dark)
    }
}
