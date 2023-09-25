//
//  MovieShowingsView.swift
//  Cinema
//
//  Created by Marius on 2023-01-05.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieShowingsView: View {
    let store: StoreOf<MovieShowings>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: .zero) {
                ZStack {
                    Text("Seansai")
                        .font(.headline)
                        .foregroundColor(.primaryElement)

                    ExitButtonView {
                        viewStore.send(.exitButtonDidTap)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()

                if viewStore.dateSelector.dates.isEmpty {
                    EmptyErrorView(title: "seansų nėra", subtitle: "pasirinkite kitą filmą")
                } else {
                    DateSelectorView(store: store.scope(
                        state: \.dateSelector,
                        action: MovieShowings.Action.dateSelector
                    ))
                    .padding(.bottom, Self.bottomPadding)

                    ShowingsTabView(store: store)
                }
            }
            .background(Color.primaryBackground)
        }
    }
}

private struct ShowingsTabView: View {
    let store: StoreOf<MovieShowings>

    private let columns = [
        GridItem(.flexible(), spacing: Self.columnSpacing),
        GridItem(.flexible())
    ]

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection:
                viewStore.binding(
                    get: \.dateSelector.selectedDate,
                    send: MovieShowings.Action.didSelectDate
                )
            ) {
                ForEach(viewStore.dateSelector.dates, id: \.self) { date in
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(columns: columns) {
                                ForEach(viewStore.showings.filter(by: date)) { showing in
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
            .background(Color.primaryBackground)
            .edgesIgnoringSafeArea(.bottom)
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

private struct ShowingView: View {
    let showing: Showing.State

    var body: some View {
        ShrinkOnPressView {
            VStack(spacing: Self.spacing) {
                ZStack(alignment: .topTrailing) {
                    Text(showing.date.toString(.timeOfDay))
                        .font(.title2.weight(.medium))
                        .foregroundColor(.primaryElement)
                        .frame(maxWidth: .infinity)

                    Image(systemName: "view.3d")
                        .font(.body.weight(.medium))
                        .foregroundColor(.tertiaryElement)
                        .opacity(showing.is3D ? 1 : 0)
                }

                Image(showing.venue.rawValue)
            }
            .padding(Self.padding)
            .background(Color.secondaryBackground)
            .cornerRadius(Self.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                    .strokeBorder(Color.primaryElement, lineWidth: Self.lineWidth)
            )
        }
    }
}

// MARK: - Constants

private extension MovieShowingsView {
    static let bottomPadding: CGFloat = 8
}

private extension ShowingsTabView {
    static let columnSpacing: CGFloat = 16
    static let scrollToTopID: String = "upandaway"
}

private extension ShowingView {
    static let cornerRadius: CGFloat = 15
    static let lineWidth: CGFloat = 2
    static let padding: CGFloat = 8
    static let spacing: CGFloat = 8
}

// MARK: - Previews

struct MovieShowingsView_Previews: PreviewProvider {
    static let showings = {
        stride(from: 0, to: 100, by: 1).map { index in
            let date = Date(timeIntervalSinceNow: .random(in: 0...index) * .hour)
            return iKinas.Previews.createShowing(date: date)
        }
    }()

    static let store = Store(
        initialState: MovieShowings.State(showings: showings.convertToIdentifiedArray()),
        reducer: MovieShowings()
    )

    static var previews: some View {
        Color.green
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                MovieShowingsView(store: store)
            }
            .preferredColorScheme(.dark)
    }
}

struct EmptyMovieShowingsView_Previews: PreviewProvider {
    static let store = Store(
        initialState: MovieShowings.State(showings: []),
        reducer: MovieShowings()
    )

    static var previews: some View {
        Color.green
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                MovieShowingsView(store: store)
            }
            .preferredColorScheme(.dark)
    }
}
