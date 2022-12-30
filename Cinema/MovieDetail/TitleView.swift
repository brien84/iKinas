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
        VStack {
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
        }
    }
}
