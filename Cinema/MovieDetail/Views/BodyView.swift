//
//  BodyView.swift
//  Cinema
//
//  Created by Marius on 2023-01-01.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct BodyView: View {
    let store: StoreOf<MovieDetail>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground

                VStack(spacing: .zero) {
                    GenresView(genres: viewStore.movie.genres)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, Self.verticalPadding)

                    if let showing = viewStore.showing {
                        Divider()
                            .padding(.horizontal)

                        ShowingView(showing: showing) {
                            viewStore.send(.openURL(viewStore.showing?.url))
                        }
                    }

                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, Self.verticalPadding)

                    JustifiedTextView(text: viewStore.movie.plot)
                        .padding(.horizontal, Self.horizontalPadding)
                        .padding(.bottom, Self.verticalPadding)
                }
            }
        }
    }
}

private struct GenresView: View {
    let genres: [String]

    var body: some View {
        HStack {
            ForEach(genres, id: \.self) { genre in
                ZStack {
                    RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .stroke(style: .init(lineWidth: Self.strokeLineWidth))
                        .foregroundColor(.secondaryElement)

                    Text(genre)
                        .font(.caption2)
                        .foregroundColor(.primaryElement)
                        .padding(.horizontal, Self.horizontalPadding)
                        .padding(.vertical, Self.verticalPadding)
                }

                .fixedSize(horizontal: true, vertical: true)
            }
        }
    }
}

private struct ShowingView: View {
    let showing: Showing
    let action: () -> Void

    var body: some View {
        HStack {
            Image(showing.venue.rawValue)

            Spacer()

            Text(showing.date.asString(.timeOfDay))
                .font(.title3.weight(.medium))

            Button {
                action()
            } label: {
                Image(systemName: "cart.circle")
                    .font(.title3)
                    .imageScale(.large)
                    .foregroundColor(.tertiaryElement)
            }
        }
        .padding(.horizontal, Self.horizontalPadding)
        .padding(.vertical, Self.verticalPadding)
    }
}

private struct JustifiedTextView: UIViewRepresentable {
    let text: String

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        let label = UILabel()

        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .justified
        label.textColor = .primaryElement
        label.font = UIFont.preferredFont(forTextStyle: .body)

        return label
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<Self>) {
        uiView.text = text
        uiView.preferredMaxLayoutWidth = UIScreen.main.bounds.width - BodyView.horizontalPadding * 2
    }
}

// MARK: - Constants

private extension BodyView {
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 8
}

private extension GenresView {
    static let cornerRadius: CGFloat = 4
    static let horizontalPadding: CGFloat = 8
    static let strokeLineWidth: CGFloat = 0.5
    static let verticalPadding: CGFloat = 5
}

private extension ShowingView {
    static let horizontalPadding: CGFloat = 32
    static let verticalPadding: CGFloat = 24
}

// MARK: - Previews

struct BodyView_Previews: PreviewProvider {
    static let showings = [
        Showing(date: Date(timeIntervalSinceNow: 60)),
        Showing(date: Date(timeIntervalSinceNow: 86400)),
        Showing(date: Date(timeIntervalSinceNow: 2 * 86400))
    ]

    static let movie = Movie(showings: showings)
    static let store = Store(initialState: MovieDetail.State(movie: movie, showing: movie.showings.first), reducer: MovieDetail())

    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ScrollView {
                BodyView(store: store)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
