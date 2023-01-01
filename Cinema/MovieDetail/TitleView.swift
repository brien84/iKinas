//
//  TitleView.swift
//  Cinema
//
//  Created by Marius on 2022-12-30.
//  Copyright © 2022 Marius. All rights reserved.
//

import SwiftUI

struct TitleView: View {
    let movie: Movie

    var body: some View {
        ZStack {
            LinearGradient(gradient: Self.backgroundGradient, startPoint: .top, endPoint: .bottom)

            VStack(spacing: Self.spacing) {
                Text(movie.title)
                    .lineLimit(2)
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                if movie.title != movie.originalTitle {
                    Text(movie.originalTitle)
                        .lineLimit(2)
                        .font(.callout.weight(.light))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text("\(movie.year) • \(movie.ageRating) • \(movie.duration.uppercased())")
                    .lineLimit(1)
                    .font(.footnote)
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
    static let movies = [
        Movie(title: String(repeating: "A", count: 15), originalTitle: String(repeating: "A", count: 15)),
        Movie(title: String(repeating: "A", count: 99), originalTitle: String(repeating: "A", count: 99)),
        Movie(title: String(repeating: "A", count: 15), originalTitle: String(repeating: "B", count: 15)),
        Movie(title: String(repeating: "A", count: 99), originalTitle: String(repeating: "B", count: 15)),
        Movie(title: String(repeating: "A", count: 15), originalTitle: String(repeating: "B", count: 99)),
        Movie(title: String(repeating: "A", count: 99), originalTitle: String(repeating: "B", count: 99))
    ]

    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()

            ScrollView {
                VStack {
                    TitleView(movie: movies[0])
                        .fixedSize(horizontal: false, vertical: true)

                    TitleView(movie: movies[1])
                        .fixedSize(horizontal: false, vertical: true)

                    TitleView(movie: movies[2])
                        .fixedSize(horizontal: false, vertical: true)

                    TitleView(movie: movies[3])
                        .fixedSize(horizontal: false, vertical: true)

                    TitleView(movie: movies[4])
                        .fixedSize(horizontal: false, vertical: true)

                    TitleView(movie: movies[5])
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }.preferredColorScheme(.dark)

    }
}
