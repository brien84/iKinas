//
//  TrailerView.swift
//  Cinema
//
//  Created by Marius on 2023-12-04.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI
import YouTubePlayerKit

struct TrailerView: View {
    let player: YouTubePlayer

    @State private var shouldPlayTrailer = false

    var body: some View {
        VStack(spacing: .zero) {
            SectionLabelView(text: "Anonsas")
                .padding(.bottom, Self.bottomPadding)

            ZStack {
                Rectangle()
                    .foregroundColor(Color.black)

                if shouldPlayTrailer {
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
                    Button {
                        shouldPlayTrailer.toggle()
                    } label: {
                        Image("play")
                    }
                }
            }
            .aspectRatio(Self.aspectRatio, contentMode: .fit)
        }
        .padding(.bottom)
    }
}

// MARK: - Constants

private extension TrailerView {
    static let aspectRatio: CGFloat = 16/9
    static let bottomPadding: CGFloat = 8
}
