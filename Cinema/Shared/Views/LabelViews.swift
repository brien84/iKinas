//
//  LabelViews.swift
//  Cinema
//
//  Created by Marius on 2022-12-20.
//  Copyright © 2022 Marius. All rights reserved.
//

import SwiftUI

struct LargeDateLabel: View {
    let date: Date

    var body: some View {
        Text(date.toString(.dayOfWeek))
            .foregroundColor(.primaryElement)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.largeTitle.bold())
    }
}

struct SmallDateLabel: View {
    let date: Date

    var body: some View {
        Text(date.toString(.monthAndDay))
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.caption.bold())
            .foregroundColor(.secondaryElement)
    }
}

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundColor(.primaryElement)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title.bold())
    }
}

// MARK: - Previews

struct LabelViews_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground

            VStack(spacing: .zero) {
                LargeDateLabel(date: Date())
                LargeDateLabel(date: Date(timeIntervalSinceNow: 84000))
                Divider().padding(16)
                SmallDateLabel(date: Date())
                SmallDateLabel(date: Date(timeIntervalSinceNow: 84000))
                Divider().padding(16)
                SectionLabel(text: "Section")
            }.padding(.horizontal)
        }.preferredColorScheme(.dark)
    }
}
