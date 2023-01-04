//
//  VenueListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-04.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import OrderedCollections
import SwiftUI

private extension VenueListView {
    struct State: Equatable {
        var selectedCity: City
        var selectedVenues: OrderedSet<Venue>
    }

    enum Action: Equatable {
        case didSelectVenue(Venue)
    }
}

private extension Settings.State {
    var state: VenueListView.State {
        .init(
            selectedCity: self.selectedCity,
            selectedVenues: self.selectedVenues
        )
    }
}

private extension VenueListView.Action {
    var action: Settings.Action {
        switch self {
        case .didSelectVenue(let venue):
            return .didSelectVenue(venue)
        }
    }
}

struct VenueListView: View {
    let store: StoreOf<Settings>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            VStack(spacing: .zero) {
                ForEach(viewStore.selectedCity.venues) { venue in
                    let isDisabled = viewStore.selectedVenues.count == 1 && viewStore.selectedVenues.contains(venue)

                    Button(
                        action: {
                            viewStore.send(.didSelectVenue(venue))
                        },
                        label: {
                            HStack {
                                Image(venue.rawValue)

                                Spacer()

                                Image(systemName: "checkmark")
                                    .foregroundColor(isDisabled ? .secondaryElement : .tertiaryElement)
                                    .hidden(!viewStore.selectedVenues.contains(venue))
                            }
                        }
                    )
                    .padding()
                    .padding(.horizontal)
                    .disabled(isDisabled)
                }
            }
            .transition(.verticalScaleAndOpacity)
            .background(
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                    .fill(Color.secondaryBackground)
                    .padding(.horizontal)
            )

        }
    }
}

// MARK: - Constants

private extension VenueListView {
    static let cornerRadius: CGFloat = 10
}

// MARK: - Previews

struct VenueListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            VenueListView(store: Store(initialState: Settings.State(), reducer: Settings()))
        }
    }
}
