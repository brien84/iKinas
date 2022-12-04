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
                                Image(venue.image)

                                Spacer()

                                Image(systemName: "checkmark")
                                    .foregroundColor(isDisabled ? .gray : Color(.tertiaryElement))
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
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.primaryBackground))
                    .padding(.horizontal)
            )

        }
    }
}

private struct VerticalScaleAndOpacity: ViewModifier {
    private var amount: CGFloat

    init(_ amount: CGFloat) {
        self.amount = amount
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(y: amount, anchor: .top)
            .opacity(amount)
    }
}

private extension AnyTransition {
    static var verticalScaleAndOpacity: AnyTransition {
        .modifier(
            active: VerticalScaleAndOpacity(0),
            identity: VerticalScaleAndOpacity(1)
        )
    }
}

// MARK: - Previews

struct VenueListView_Previews: PreviewProvider {
    static var previews: some View {
        VenueListView(store: Store(initialState: Settings.State(), reducer: Settings()))
    }
}
