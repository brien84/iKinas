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

                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: Self.horizontalSpacing) {
                                ForEach(viewStore.restOfTheWeek, id: \.self) { date in
                                    Button {
                                        viewStore.send(.didSelect(date: date))
                                    } label: {
                                        VStack {
                                            Text(date.toString(.shortDayOfWeek))
                                                .font(.caption.weight(.bold))
                                                .foregroundColor(date == viewStore.selectedDate ? .tertiaryElement : .primaryElement)

                                            Text(date.toString(.shortMonthAndDay))
                                                .font(.caption)
                                                .foregroundColor(date == viewStore.selectedDate ? .tertiaryElement : .secondaryElement)
                                        }
                                    }
                                    .id(date)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .onChange(of: viewStore.selectedDate) { newValue in
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
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
    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()

            DateSelectorView(store: Store(initialState: DateSelector.State(), reducer: DateSelector()))
                .preferredColorScheme(.dark)
        }
    }
}
