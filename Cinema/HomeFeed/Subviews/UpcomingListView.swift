//
//  UpcomingListView.swift
//  Cinema
//
//  Created by Marius on 2023-10-02.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct UpcomingListView: View {
    let store: StoreOf<HomeFeed>

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .fill(Color.secondaryBackground)

            VStack {
                ScheduleButton(store: store)

                LazyVStack(spacing: .zero) {
                    ForEachStore(store.scope(
                        state: \.showings,
                        action: HomeFeed.Action.showing(id:action:)
                    )) {
                        ShowingView(store: $0)
                    }
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

private struct ScheduleButton: View {
    let store: StoreOf<HomeFeed>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button {
                viewStore.send(.scheduleButtonDidTap)
            } label: {
                HStack {
                    Text("Artimiausi")
                        .font(.title2.bold())
                        .foregroundColor(.primaryElement)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.forward")
                        .font(.headline.bold())
                        .foregroundColor(.tertiaryElement)
                }
            }
        }
    }
}

private struct ShowingView: View {
    let store: StoreOf<Showing>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: .zero) {
                ShrinkOnPressView {
                    HStack {
                        NetworkImageView(store: store.scope(
                            state: \.networkImage,
                            action: Showing.Action.networkImage
                        ))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Self.width, height: Self.height)
                        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))

                        TitleView(showing: viewStore.state)

                        VStack(alignment: .trailing, spacing: 4) {
                            HStack {
                                Image(systemName: "view.3d")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.tertiaryElement)
                                    .opacity(viewStore.is3D ? 1 : 0)

                                Text(viewStore.date.formatted(.timeOfDay))
                                    .font(.title2.weight(.medium))
                                    .foregroundColor(.primaryElement)
                            }

                            Image(viewStore.venue.rawValue)
                        }
                        .scaleEffect(0.9, anchor: .trailing)
                    }
                    .background(Color.secondaryBackground)
                    .onTapGesture {
                        viewStore.send(.didSelect)
                    }
                }

                Divider()
                    .padding(.vertical, 8)
            }
        }
    }
}

private struct TitleView: View {
    private let title: String
    private let originalTitle: String

    init(showing: Showing.State) {
        self.title = showing.title
        self.originalTitle = showing.originalTitle
    }

    var body: some View {
        if title == originalTitle {
            Text(title)
                .font(.callout.bold())
                .foregroundColor(.primaryElement)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.callout.bold())
                    .lineLimit(2)
                    .foregroundColor(.primaryElement)

                Text(originalTitle)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.secondaryElement)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Constants

private extension ShowingView {
    static let cornerRadius: CGFloat = 10
    static let height: CGFloat = 60
    static let width: CGFloat = 60
}

private extension UpcomingListView {
    static let cornerRadius: CGFloat = 15
}

// MARK: - Previews

struct UpcomingListView_Previews: PreviewProvider {
    static let showings: IdentifiedArrayOf<Showing.State> = {
        stride(from: 1, through: 5, by: 1).map { _ in
            iKinas.Previews.createShowing()
        }.convertToIdentifiedArray()
    }()

    static let store = Store(
        initialState: HomeFeed.State(showings: showings),
        reducer: HomeFeed()
    )

    static var previews: some View {
        UpcomingListView(store: store)
            .fixedSize(horizontal: false, vertical: true)
    }
}
