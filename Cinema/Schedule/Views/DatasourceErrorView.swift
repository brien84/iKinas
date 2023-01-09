//
//  DatasourceErrorView.swift
//  Cinema
//
//  Created by Marius on 2023-01-03.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

struct DatasourceErrorView: View {

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            GeometryReader { proxy in
                let midPoint = CGPoint(
                    x: proxy.frame(in: .local).midX,
                    y: proxy.frame(in: .local).midY
                )

                Text("nieko nerodo")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryElement)
                    .position(midPoint)
                    .offset(y: Self.titleYOffset)

                Image("empty")
                    .frame(maxWidth: .infinity)
                    .position(midPoint)
                    .offset(y: Self.imageYOffset)

                Text("pasirinkite kitą dieną")
                    .font(.body)
                    .foregroundColor(.secondaryElement)
                    .position(midPoint)
                    .offset(y: Self.subtitleYOffset)
            }
        }
    }

}

// MARK: - Constants

extension DatasourceErrorView {
    static let imageYOffset: CGFloat = -16
    static let subtitleYOffset: CGFloat = 80
    static let titleYOffset: CGFloat = -88
}

// MARK: - Previews

struct DatasourceErrorView_Previews: PreviewProvider {
    static var previews: some View {
        DatasourceErrorView()
            .preferredColorScheme(.dark)
    }
}
