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

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Self.verticalSpacing) {
                SectionLabel(text: "Seansai")

                ForEach(viewStore.sections) { section in
                    Button {
                        viewStore.send(.didSelectSection(section), animation: .easeInOut)
                    } label: {
                        Text(section.date.sectionFormat)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(viewStore.selectedSection == section ? .tertiaryElement : .secondaryElement)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .transition(.verticalScaleAndOpacity)
            }
            .padding()
        }
    }
}

private extension Date {
    var sectionFormat: String {
        if Calendar.current.isDateInToday(self) { return "Šiandien" }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "lt")
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: self)
    }
}

// MARK: - Constants

private extension DetailShowingsView {
    static let verticalSpacing: CGFloat = 16
}

// MARK: - Previews

struct MovieShowingsView_Previews: PreviewProvider {
    static let showings = [
        Showing(date: Date(timeIntervalSinceNow: 60)),
        Showing(date: Date(timeIntervalSinceNow: 60)),
        Showing(date: Date(timeIntervalSinceNow: 86400)),
        Showing(date: Date(timeIntervalSinceNow: 2 * 86400)),
        Showing(date: Date(timeIntervalSinceNow: 3 * 86400)),
        Showing(date: Date(timeIntervalSinceNow: 4 * 86400))
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
