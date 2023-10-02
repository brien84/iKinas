//
//  DateView.swift
//  Cinema
//
//  Created by Marius on 2023-10-01.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

struct DateView: View {
    private let date: Date
    private let style: DateView.Style

    init(date: Date) {
        self.date = date
        self.style = .compact
    }

    private init(date: Date, style: DateView.Style) {
        self.date = date
        self.style = style
    }

    var body: some View {
        if style == .compact {
            Text(date.formatted(.monthAndDay))
                .font(.caption.bold())
                .foregroundColor(.secondaryElement)
                .textCase(.uppercase)
        } else {
            Text(date.formatted(.dayOfWeek))
                .font(.largeTitle.bold())
                .foregroundColor(.primaryElement)
        }
    }
}

extension DateView {
    enum Style {
        case compact
        case large
    }

    func labelStyle(_ style: DateView.Style) -> DateView {
        DateView(date: self.date, style: style)
    }
}

// MARK: - Previews

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DateView(date: Date())
            DateView(date: Date())
                .labelStyle(.large)
                .padding(.bottom)

            DateView(date: Date(timeIntervalSinceNow: .fullDay))
            DateView(date: Date(timeIntervalSinceNow: .fullDay))
                .labelStyle(.large)
                .padding(.bottom)

            DateView(date: Date(timeIntervalSinceNow: .fullDay * 2))
            DateView(date: Date(timeIntervalSinceNow: .fullDay * 2))
                .labelStyle(.large)
        }
        .preferredColorScheme(.dark)
    }
}
