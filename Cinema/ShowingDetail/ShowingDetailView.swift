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

                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(columns: columns) {
                                ForEach(viewStore.showingItems) { item in
                                    ShowingView(showing: item.showing)
                                        .transition(.opacity)
                                        .simultaneousGesture(
                                            TapGesture().onEnded { _ in
                                                viewStore.send(.didSelectShowing(item.showing))
                                            }
                                        )
                                }
                            }
                            .padding()
                        }
                        .id(viewStore.selectedDate)
                    }
                }
                .frame(height: proxy.size.height * Self.heightMultiplier)
                .position(
                    x: proxy.frame(in: .local).midX,
                    y: proxy.frame(in: .local).midY + proxy.size.height * Self.framePositionYMultiplier
                )
            }
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
                                        Text(date.toString(.shortDayOfWeek))
                                            .font(.footnote.weight(.medium))
                                        Text(date.toString(.shortMonthAndDay))
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
            }
            .fixedSize(horizontal: false, vertical: true)

        }
    }
}

private struct ShowingView: View {
    let showing: Showing

    var body: some View {
        ShrinkOnPressView {
            ZStack {
                RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                    .strokeBorder(Color.primaryElement, lineWidth: Self.lineWidth)
                    .background(
                        RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                            .fill(Color.secondaryBackground)
                    )

                VStack {
                    Text(showing.date.toString(.timeOfDay))
                        .font(.title3.weight(.medium))
                        .foregroundColor(.primaryElement)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Text("3D")
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(.tertiaryElement)
                                .hidden(!showing.is3D)
                        )

                    Image(showing.venue.rawValue)
                }
                .padding(Self.padding)
            }
        }
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

private extension ShowingView {
    static let cornerRadius: CGFloat = 15
    static let lineWidth: CGFloat = 2
    static let padding: CGFloat = 8
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
            Color.green
                .ignoresSafeArea()

            ShowingDetailView(store: store)
        }
        .preferredColorScheme(.dark)
    }
}
