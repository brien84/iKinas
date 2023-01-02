//
//  CityListView.swift
//  Cinema
//
//  Created by Marius on 2022-12-04.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

private extension CityListView {
    struct State: Equatable {
        var selectedCity: City
    }

    enum Action: Equatable {
        case didSelectCity(City)
    }
}

private extension Settings.State {
    var state: CityListView.State {
        .init(selectedCity: self.selectedCity)
    }
}

private extension CityListView.Action {
    var action: Settings.Action {
        switch self {
        case .didSelectCity(let city):
            return .didSelectCity(city)
        }
    }
}

struct CityListView: View {
    let store: StoreOf<Settings>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            VStack {
                ForEach(City.allCases) { city in

                    Button(
                        action: {
                            viewStore.send(.didSelectCity(city), animation: .easeInOut)
                        },
                        label: {
                            Text(city.description)
                                .padding()
                                .font(.title3)
                                .foregroundColor(city == viewStore.selectedCity ? .tertiaryElement : .secondaryElement)
                        }
                    )

                    if city == viewStore.selectedCity {
                        VenueListView(store: store)
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct CityListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            CityListView(store: Store(initialState: Settings.State(), reducer: Settings()))
        }
    }
}
