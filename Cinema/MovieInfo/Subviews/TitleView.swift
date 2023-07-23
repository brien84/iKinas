//
//  TitleView.swift
//  Cinema
//
//  Created by Marius on 2022-12-30.
//  Copyright © 2022 Marius. All rights reserved.
//

import SwiftUI

struct TitleView: View {
    let showing: Showing

    var body: some View {
        ZStack {
            LinearGradient(gradient: Self.backgroundGradient, startPoint: .top, endPoint: .bottom)

            VStack(spacing: Self.spacing) {
                Text(showing.title)
                    .lineLimit(2)
                    .font(.title.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showing.title != showing.originalTitle {
                    Text(showing.originalTitle)
                        .lineLimit(2)
                        .font(.callout.weight(.light))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text("\(showing.year) • \(showing.ageRating) • \(showing.duration.uppercased())")
                    .lineLimit(1)
                    .font(.footnote.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundColor(.primaryElement)
            .padding([.horizontal, .top])
            .padding(.bottom, Self.bottomPadding)
        }
    }
}

// MARK: - Constants

private extension TitleView {
    static let backgroundGradient = Gradient(colors: [
        .clear,
        .primaryBackground.opacity(0.2),
        .primaryBackground.opacity(0.3),
        .primaryBackground.opacity(0.4),
        .primaryBackground.opacity(0.45),
        .primaryBackground.opacity(0.5),
        .primaryBackground.opacity(0.55),
        .primaryBackground.opacity(0.6),
        .primaryBackground.opacity(0.7),
        .primaryBackground.opacity(0.8)
    ])

    static let bottomPadding: CGFloat = 8
    static let spacing: CGFloat = 8
}

// MARK: - Previews

struct TitleView_Previews: PreviewProvider {
    static let showings = [
        Showing(originalTitle: String(repeating: "A", count: 15), title: String(repeating: "A", count: 15)),
        Showing(originalTitle: String(repeating: "A", count: 99), title: String(repeating: "A", count: 99)),
        Showing(originalTitle: String(repeating: "B", count: 15), title: String(repeating: "A", count: 15)),
        Showing(originalTitle: String(repeating: "B", count: 15), title: String(repeating: "A", count: 99)),
        Showing(originalTitle: String(repeating: "B", count: 99), title: String(repeating: "A", count: 15)),
        Showing(originalTitle: String(repeating: "B", count: 99), title: String(repeating: "A", count: 99))
    ]

    static var previews: some View {
        ScrollView {
            VStack {
                TitleView(showing: showings[0])
                TitleView(showing: showings[1])
                TitleView(showing: showings[2])
                TitleView(showing: showings[3])
                TitleView(showing: showings[4])
                TitleView(showing: showings[5])
            }
        }
        .background(
            Image("posterPreview")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        )
        .preferredColorScheme(.dark)
    }
}
