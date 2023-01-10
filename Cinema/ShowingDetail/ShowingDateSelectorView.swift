//
//  ShowingDateSelectorView.swift
//  Cinema
//
//  Created by Marius on 2023-01-10.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

private extension ShowingDateSelectorView {
    struct State: Equatable {
        let dates: [Date]
        var selectedDate: Date
    }

    enum Action: Equatable {
        case didSelectDate(Date)
    }
}

private extension ShowingDetail.State {
    var state: ShowingDateSelectorView.State {
        .init(dates: self.dates, selectedDate: self.selectedDate)
    }
}

private extension ShowingDateSelectorView.Action {
    var action: ShowingDetail.Action {
        switch self {
        case .didSelectDate(let date):
            return .didSelectDate(date)
        }
    }
}

struct ShowingDateSelectorView: View {
    let store: StoreOf<ShowingDetail>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            ZStack {
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

// MARK: - Previews

struct ShowingDateSelectorView_Previews: PreviewProvider {
    static let showings = {
        var showings = [Showing]()

        for _ in 0...10 {
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

            ZStack {
                Color.primaryBackground
                ShowingDateSelectorView(store: store)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .preferredColorScheme(.dark)
    }
}
