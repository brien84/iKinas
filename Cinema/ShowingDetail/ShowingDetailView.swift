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

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground

                VStack(spacing: .zero) {
                    Text("Seansai")
                        .font(.headline)
                        .foregroundColor(.primaryElement)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(
                            ExitButtonView {
                                viewStore.send(.exitButtonDidTap)
                            }
                            .frame(alignment: .trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                        )

                    if viewStore.dates.isEmpty {
                        EmptyErrorView(title: "seansų nėra", subtitle: "pasirinkite kitą filmą")
                    } else {
                        ShowingDateSelectorView(store: store)
                        ShowingDetailTabView(store: store)
                    }
                }
            }
        }
    }
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
        Color.green
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                ShowingDetailView(store: store)
            }
            .preferredColorScheme(.dark)
    }
}
