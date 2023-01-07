//
//  ShowingDetailView.swift
//  Cinema
//
//  Created by Marius on 2023-01-05.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ShowingDetailView: View {
    let store: StoreOf<ShowingDetail>

    private let columns = [GridItem(.flexible(), spacing: Self.columnSpacing), GridItem(.flexible())]

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                VStack(spacing: .zero) {
                    ShowingDateSelector(store: store)

                    ZStack {
                        Color.primaryBackground
                            .edgesIgnoringSafeArea(.bottom)


                    }
                }
                .padding(.bottom)
                .frame(height: proxy.size.height * Self.heightMultiplier)
                .position(
                    x: proxy.frame(in: .local).midX,
                    y: proxy.frame(in: .local).midY + proxy.size.height * Self.framePositionYMultiplier
                )
            }
            .ignoresSafeArea(edges: .vertical)
            .transition(.trailingSlideIn)
            .zIndex(Self.zIndex)
        }
    }
}

private struct ShowingDateSelector: View {
    let store: StoreOf<ShowingDetail>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                LinearGradient(gradient: Self.backgroundGradient, startPoint: .top, endPoint: .bottom)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: .zero) {
                        ForEach(viewStore.dates, id: \.self) { date in
                            Button {
                                viewStore.send(.didSelectDate(date), animation: .easeInOut)
                            } label: {
                                ZStack {
                                    VStack(spacing: .zero) {
                                        Text(date.shortWeekdayFormat)
                                            .font(.footnote.weight(.medium))
                                        Text(date.shortDateFormat)
                                            .font(.footnote)
                                    }
                                    .foregroundColor(viewStore.selectedDate == date ? .tertiaryElement : .primaryElement)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                }
            }.fixedSize(horizontal: false, vertical: true)

        }
    }
}

private extension Date {
    var shortWeekdayFormat: String {
        if Calendar.current.isDateInToday(self) { return "ŠND" }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "lt")
        dateFormatter.shortWeekdaySymbols = ["SEK", "PIR", "ANT", "TRE", "KET", "PEN", "ŠEŠ"]
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }

    var shortDateFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "lt")
        dateFormatter.shortMonthSymbols = ["Sau", "Vas", "Kov", "Bal", "Geg", "Bir", "Lie", "Rgp", "Rgs", "Spa", "Lap", "Gru"]
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: self)
    }
}

// MARK: - Constants

private extension ShowingDetailView {
    static let columnSpacing: CGFloat = 16
    static let heightMultiplier: CGFloat = 0.6
    static let framePositionYMultiplier = (1 - Self.heightMultiplier) * 0.5
    static let zIndex: CGFloat = 100
}

private extension ShowingDateSelector {
    static let backgroundGradient = Gradient(colors: [
        .primaryBackground.opacity(0.6),
        .primaryBackground.opacity(0.65),
        .primaryBackground.opacity(0.7),
        .primaryBackground.opacity(0.75)
    ])
}

// MARK: - Previews

struct ShowingDetailView_Previews: PreviewProvider {
    static let showings = {
        var showings = [Showing]()

        for _ in 0...300 {
            let date = Date(timeIntervalSinceNow: Double.random(in: 0...8) * 86400)
            showings.append(Showing(date: date, is3D: true))
        }

        return showings
    }()

    static let store = Store(
        initialState: ShowingDetail.State(movie: Movie(showings: showings)),
        reducer: ShowingDetail()
    )

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ShowingDetailView(store: store)
        }
        .preferredColorScheme(.dark)
    }
}
