//
//  MovieDetailView.swift
//  Cinema
//
//  Created by Marius on 2022-12-29.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MovieDetailView: View {
    let store: StoreOf<MovieDetail>

    var body: some View {
        WithViewStore(store) { _ in
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: .zero) {
                        Poster()

                        VStack(spacing: .zero) {
                            TitleView()

                            BodyView()
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

struct Poster: View {
    var body: some View {
        Image("posterPreview")
            .resizable()
            .frame(maxWidth: .infinity)
            .aspectRatio(2/3, contentMode: .fit)
    }
}

struct TitleView: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.8)

            VStack {
                Text("Pavadinimas")
                    .font(.title)

                Text("Title")
                    .font(.title2)

                Text("2021 • N-18 • 112 min")
                    .font(.footnote)
            }
            .foregroundColor(.white)
            .padding()

        }
    }
}

struct BodyView: View {
    var body: some View {
        ZStack {
            Color.orange

            Text(String(repeating: "X", count: 3000))
        }
    }
}
