//
//  ShowingDetailTabView.swift
//  Cinema
//
//  Created by Marius on 2023-01-10.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ShowingDetailTabView: View {
    let store: StoreOf<ShowingDetail>

    private let columns = [GridItem(.flexible(), spacing: Self.columnSpacing), GridItem(.flexible())]

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground

                TabView(selection: viewStore.binding(
                    get: \.selectedDate,
                    send: ShowingDetail.Action.didSelectDate)
                ) {
                    ForEach(viewStore.dates, id: \.self) { date in
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVGrid(columns: columns) {
                                    ForEach(viewStore.state.getShowings(at: date)) { showing in
                                        ShowingView(showing: showing)
                                            .simultaneousGesture(
                                                TapGesture().onEnded { _ in
                                                    viewStore.send(.didSelectShowing(showing))
                                                }
                                            )
                                    }
                                }
                                .padding()
                                .id(Self.scrollToTopID)
                            }
                            .tag(date)
                            .onDisappear {
                                DispatchQueue.main.async {
                                    proxy.scrollTo(Self.scrollToTopID, anchor: .top)
                                }
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .edgesIgnoringSafeArea(.bottom)
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
                    ZStack(alignment: .topTrailing) {
                        Text(showing.date.toString(.timeOfDay))
                            .font(.title2.weight(.medium))
                            .foregroundColor(.primaryElement)
                            .frame(maxWidth: .infinity)

                        Image(systemName: "view.3d")
                            .font(.body.weight(.medium))
                            .foregroundColor(.tertiaryElement)
                            .hidden(!showing.is3D)
                    }

                    Image(showing.venue.rawValue)
                }
                .padding(Self.padding)
            }
        }
    }
}

// MARK: - Constants

private extension ShowingDetailTabView {
    static let columnSpacing: CGFloat = 16
    static let scrollToTopID: String = "upandaway"
}

private extension ShowingView {
    static let cornerRadius: CGFloat = 15
    static let lineWidth: CGFloat = 2
    static let padding: CGFloat = 8
}

// MARK: - Previews

struct ShowingDetailTabView_Previews: PreviewProvider {
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
        ShowingDetailTabView(store: store)
            .edgesIgnoringSafeArea(.all)
            .preferredColorScheme(.dark)
    }
}
