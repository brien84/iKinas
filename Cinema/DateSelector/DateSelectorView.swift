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
            ZStack {
                HStack(spacing: .zero) {
                    Button {
                        viewStore.send(.didSelect(date: viewStore.today))
                    } label: {
                        Image(systemName: "house")
                            .foregroundColor(viewStore.isTodaySelected ? .tertiaryElement : .primaryElement)
                            .padding(.horizontal)
                    }

                    Divider()

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: .horizontalSpacing) {
                            ForEach(viewStore.restOfTheWeek, id: \.self) { date in
                                Button {
                                    viewStore.send(.didSelect(date: date))
                                } label: {
                                    VStack {
                                        Text(date.shortWeekdayFormat)
                                            .font(.caption.weight(.bold))
                                            .foregroundColor(date == viewStore.selectedDate ? .tertiaryElement : .primaryElement)

                                        Text(date.shortDateFormat)
                                            .font(.caption2)
                                            .foregroundColor(date == viewStore.selectedDate ? .tertiaryElement : .secondaryElement)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .disabled(viewStore.isDisabled)
            .padding(.vertical)
            .frame(height: .height)
            .background(Color.secondaryBackground)
        }
    }
}

private extension CGFloat {
    static let horizontalSpacing: CGFloat = 24
    static let height: CGFloat = 60
}

private extension Date {
    var shortWeekdayFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "lt")
        dateFormatter.shortWeekdaySymbols = ["SEK", "PIR", "ANT", "TRE", "KET", "PEN", "ŠEŠ"]
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }

    var shortDateFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "lt")
        dateFormatter.shortMonthSymbols = ["Sau", "Vas", "Kov", "Bal", "Geg", "Bir", "Lie", "Rgp", "Rgs", "Spa", "Lap", "Gru"]
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: self)
    }
}

// MARK: - Previews

struct DateSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green

            DateSelectorView(store: Store(initialState: DateSelector.State(), reducer: DateSelector()))
                .preferredColorScheme(.dark)
        }

    }
}
