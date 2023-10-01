//
//  DateSelectorView.swift
//  Cinema
//
//  Created by Marius on 2022-12-15.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct DateSelectorView: View {
    let store: StoreOf<DateSelector>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Self.horizontalSpacing) {
                        ForEach(viewStore.dates, id: \.self) { date in
                            Button {
                                viewStore.send(.didSelect(date: date))
                            } label: {
                                VStack {
                                    let isDateSelected = date == viewStore.selectedDate

                                    Text(date.toString(.shortDayOfWeek))
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(isDateSelected ? .tertiaryElement : .primaryElement)

                                    Text(date.toString(.shortMonthAndDay))
                                        .font(.caption)
                                        .foregroundColor(isDateSelected ? .tertiaryElement : .secondaryElement)
                                }
                            }
                            .id(date)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: viewStore.selectedDate) { newValue in
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            .background(Color.primaryBackground)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Constants

private extension DateSelectorView {
    static let horizontalSpacing: CGFloat = 24
}

// MARK: - Previews

struct DateSelectorView_Previews: PreviewProvider {
    static let dates: [Date] = {
        stride(from: 0, to: 7, by: 1).map { index in
            Date(timeIntervalSinceNow: Double(86400 * index))
        }
    }()

    static let store = Store(
        initialState: DateSelector.State(dates: dates, selectedDate: dates.first!),
        reducer: DateSelector()
    )

    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()

            DateSelectorView(store: store)
                .preferredColorScheme(.dark)
        }
    }
}
