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
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: .zero) {
                            ForEach(viewStore.dates, id: \.self) { date in
                                Button {
                                    viewStore.send(.didSelectDate(date))
                                } label: {
                                    let isSelected = date == viewStore.selectedDate

                                    ZStack {
                                        RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                                            .fill(Color.tertiaryElement)
                                            .opacity(isSelected ? 1 : 0)

                                        VStack(spacing: .zero) {
                                            Text(date.toString(.shortDayOfWeek))
                                                .font(.footnote.weight(isSelected ? .bold : .medium))
                                                .foregroundColor(isSelected ? .primaryElement : .secondaryElement)

                                            Text(date.toString(.shortMonthAndDay))
                                                .font(.footnote.weight(isSelected ? .bold : .medium))
                                                .foregroundColor(isSelected ? .primaryElement : .secondaryElement)
                                        }
                                        .padding(.horizontal, Self.buttonHorizontalPadding)
                                        .padding(.vertical, Self.buttonVerticalPadding)
                                    }
                                }
                                .id(date)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, Self.verticalPadding)
                    }
                    .onChange(of: viewStore.selectedDate) { newValue in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Constants

private extension ShowingDateSelectorView {
    static let buttonHorizontalPadding: CGFloat = 12
    static let buttonVerticalPadding: CGFloat = 8
    static let cornerRadius: CGFloat = 16
    static let verticalPadding: CGFloat = 4
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
