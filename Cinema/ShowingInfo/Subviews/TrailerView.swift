//
//  TrailerView.swift
//  Cinema
//
//  Created by Marius on 2023-12-04.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import YouTubePlayerKit

struct TrailerView: View {
    let store: StoreOf<ShowingInfo>

    @State private var isPlayingTrailer = false

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: .zero) {
                SectionLabelView(text: "Anonsas")
                    .padding(.bottom, Self.bottomPadding)

                ZStack {
                    Rectangle()
                        .foregroundColor(Color.black)

                    if let player = viewStore.player, isPlayingTrailer {
                        YouTubePlayerView(player) { state in
                            switch state {
                            case .idle:
                                ProgressView()
                            case .ready:
                                EmptyView()
                            case .error:
                                Text("klaida.")
                            }
                        }
                    } else {
                        ZStack {
                            NetworkImageView(store: store.scope(
                                state: \.trailerThumbnail,
                                action: ShowingInfo.Action.trailerThumbnail
                            ))

                            Button {
                                isPlayingTrailer.toggle()
                            } label: {
                                Image("play")
                            }
                        }
                    }
                }
                .aspectRatio(Self.aspectRatio, contentMode: .fit)
            }
            .padding(.bottom)
        }
    }
}

// MARK: - Constants

private extension TrailerView {
    static let aspectRatio: CGFloat = 16/9
    static let bottomPadding: CGFloat = 8
}
