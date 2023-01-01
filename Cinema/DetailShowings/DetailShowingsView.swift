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

                    if viewStore.selectedSection == section {
                        LazyVGrid(columns: columns) {
                            ForEach(section.showingItems) { showingItem in
                                ShowingView(showing: showingItem.showing)
                                    .simultaneousGesture(
                                        TapGesture().onEnded { _ in
                                            viewStore.send(.didSelectShowing(showingItem.showing))
                                        }
                                    )
                            }
                        }
                    }
                }
                .transition(.verticalScaleAndOpacity)
            }
            .padding(.horizontal)
            .padding(.bottom, Self.bottomPadding)
        }
    }
}

private struct ShowingView: View {
    let showing: Showing

    @State private var isBeingPressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .strokeBorder(Color.primaryElement, lineWidth: Self.lineWidth)
                .background(
                    RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                        .fill(Color.secondaryBackground)
                )

            VStack {
                Text(showing.date.asString(.timeOfDay))
                    .font(.title3.bold())
                    .foregroundColor(.primaryElement)

                Image(showing.venue.rawValue)
            }
            .padding(Self.padding)
        }
        .opacity(isBeingPressed ? Self.longPressOpacity : 1)
        .scaleEffect(isBeingPressed ? Self.longPressScaleEffect : 1)
        .onTapGesture { }
        .onLongPressGesture(perform: { }, onPressingChanged: { isPressing in
            withAnimation(Self.springAnimation) {
                isBeingPressed = isPressing
            }
        })
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
    static let bottomPadding: CGFloat = 8
}

private extension ShowingView {
    static let cornerRadius: CGFloat = 15
    static let lineWidth: CGFloat = 2
    static let longPressOpacity: CGFloat = 0.95
    static let longPressScaleEffect: CGFloat = 0.95
    static let padding: CGFloat = 8

    static let springAnimation: Animation = .spring(
        response: 0.5,
        dampingFraction: 0.5
    )
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
