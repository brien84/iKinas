//
//  SettingsView.swift
//  Cinema
//
//  Created by Marius on 2022-12-03.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    private let store: StoreOf<Settings>

    init(store: StoreOf<Settings>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                VStack {
                    Text("Pasirinkite teatrus")
                        .font(.title)
                        .foregroundColor(.primaryElement)

                    CityListView(store: store)
                }
                .modifier(Scale320X568Screen())
            }
            .overlay(
                ExitButtonView {
                    viewStore.send(.saveSettings)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            )
            .onAppear {
                viewStore.send(.loadSettings)
            }
        }
    }
}

private struct CityListView: View {
    let store: StoreOf<Settings>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ForEach(City.allCases) { city in
                    Button(
                        action: {
                            viewStore.send(.didSelectCity(city), animation: .easeInOut)
                        },
                        label: {
                            Text(city.description)
                                .font(.title2)
                                .foregroundColor(city == viewStore.selectedCity ? .tertiaryElement : .secondaryElement)
                        }
                    )
                    .padding(.horizontal)
                    .padding(.vertical, Self.verticalPadding)

                    if city == viewStore.selectedCity {
                        VenueListView(store: store)
                    }
                }
            }
        }
    }
}

private struct VenueListView: View {
    let store: StoreOf<Settings>

    var body: some View {
        WithViewStore(store) { viewStore in
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
                                    .opacity(viewStore.selectedVenues.contains(venue) ? 1 : 0)
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

/// Scales down the view if screen size of the device is 320x568.
///
/// Used on iPod Touch and iPhone SE 1st Gen devices.
/// Can be deleted when iOS 15 is no longer supported.
private struct Scale320X568Screen: ViewModifier {
    private var isActive: Bool {
        UIScreen.main.bounds.size == CGSize(width: 320, height: 568)
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 0.9 : 1)
    }
}

// MARK: - Constants

private extension CityListView {
    static let verticalPadding: CGFloat = 10
}

private extension VenueListView {
    static let cornerRadius: CGFloat = 10
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: Store(initialState: Settings.State(), reducer: Settings()))
    }
}
