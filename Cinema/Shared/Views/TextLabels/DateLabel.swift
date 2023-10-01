//
//  DateLabel.swift
//  Cinema
//
//  Created by Marius on 2023-10-01.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

struct DateLabel: View {
    private let date: Date
    private let style: DateLabel.Style

    init(date: Date) {
        self.date = date
        self.style = .compact
    }

    private init(date: Date, style: DateLabel.Style) {
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

extension DateLabel {
    enum Style {
        case compact
        case large
    }

    func labelStyle(_ style: DateLabel.Style) -> DateLabel {
        DateLabel(date: self.date, style: style)
    }
}

// MARK: - Previews

struct DateLabel_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DateLabel(date: Date())
            DateLabel(date: Date())
                .labelStyle(.large)
                .padding(.bottom)

            DateLabel(date: Date(timeIntervalSinceNow: .fullDay))
            DateLabel(date: Date(timeIntervalSinceNow: .fullDay))
                .labelStyle(.large)
                .padding(.bottom)

            DateLabel(date: Date(timeIntervalSinceNow: .fullDay * 2))
            DateLabel(date: Date(timeIntervalSinceNow: .fullDay * 2))
                .labelStyle(.large)
        }
        .preferredColorScheme(.dark)
    }
}
