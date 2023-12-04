//
//  ShowingInfoBody.swift
//  Cinema
//
//  Created by Marius on 2023-01-01.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import OrderedCollections
import SwiftUI

struct ShowingInfoBody: View {
    let store: StoreOf<ShowingInfo>

    @State private var isDisplayingTicketURL = false

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground

                VStack(spacing: .zero) {
                    GenresView(genres: viewStore.showing.genres)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, Self.verticalPadding)

                    if isDisplayingTicketURL {
                        if viewStore.shouldDisplayTicketURL {
                            Divider()
                                .padding(.horizontal)

                            TicketURLView(showing: viewStore.showing) {
                                viewStore.send(.setShowingURL(viewStore.showing.url))
                            }
                            .transition(.verticalScaleAndOpacity)
                        }
                    }

                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, Self.verticalPadding)

                    JustifiedTextView(text: viewStore.showing.plot)
                        .padding(.horizontal, Self.horizontalPadding)
                        .padding(.bottom, Self.bottomPadding)
                }
            }
            .onAppear {
                // Delay to sync animation with `NavigationBar` animation.
                withAnimation(.default.delay(Self.showingAnimationDelay)) {
                    isDisplayingTicketURL = true
                }
            }
        }
    }
}

private struct GenresView: View {
    let genres: OrderedSet<String>

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

private struct TicketURLView: View {
    let showing: Showing.State
    let action: () -> Void

    var body: some View {
        HStack {
            Image(showing.venue.rawValue)

            Spacer()

            Text(showing.date.formatted(.timeOfDay))
                .font(.title2.weight(.medium))
                .foregroundColor(.primaryElement)

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
        uiView.preferredMaxLayoutWidth = UIScreen.main.bounds.width - ShowingInfoBody.horizontalPadding * 2
    }
}

// MARK: - Constants

private extension ShowingInfoBody {
    static let showingAnimationDelay: CGFloat = 0.475
    static let bottomPadding: CGFloat = 16
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 8
}

private extension GenresView {
    static let cornerRadius: CGFloat = 4
    static let horizontalPadding: CGFloat = 8
    static let strokeLineWidth: CGFloat = 0.5
    static let verticalPadding: CGFloat = 5
}

private extension TicketURLView {
    static let horizontalPadding: CGFloat = 32
    static let verticalPadding: CGFloat = 24
}
