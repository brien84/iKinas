//
//  MovieClientErrorView.swift
//  Cinema
//
//  Created by Marius on 2022-12-25.
//  Copyright © 2022 Marius. All rights reserved.
//

import SwiftUI

struct MovieClientErrorView: View {
    private let text: String
    private let buttonText: String
    let action: () -> Void

    @State private var didAppear = false

    init(_ error: MovieClient.Error, action: @escaping () -> Void) {
        switch error {
        case .requiresUpdate:
            self.text = "nebepalaikoma aplikacijos versija"
            self.buttonText = "atnaujinti"

        case .network, .decoding:
            self.text = "nepavyko prisijungti"
            self.buttonText = "bandyti vėl"
        }

        self.action = action
    }

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            // Using `GeometryReader` to place an `Image` exactly at the center of the screen,
            // so it aligns perfectly between transitions with `LoadingView`.
            GeometryReader { proxy in
                let midPoint = CGPoint(
                    x: proxy.frame(in: .local).midX,
                    y: proxy.frame(in: .local).midY
                )

                Text(text)
                    .font(.title.bold())
                    .foregroundColor(.primaryElement)
                    .multilineTextAlignment(.center)
                    .position(midPoint)
                    .offset(y: Self.textYOffset)
                    .opacity(didAppear ? 1 : 0)

                Image("empty")
                    .frame(maxWidth: .infinity)
                    .position(midPoint)
                    .onTapGesture {
                        action()
                    }

                Button {
                    action()
                } label: {
                    Text(buttonText)
                        .font(Font.footnote.weight(.semibold))
                        .foregroundColor(.primaryElement)
                        .padding(Self.buttonPadding)
                        .background(
                            RoundedRectangle(cornerRadius: Self.buttonCornerRadius)
                                .strokeBorder(Color.secondaryElement, lineWidth: Self.buttonLineWidth)
                                .background(
                                    RoundedRectangle(cornerRadius: Self.buttonCornerRadius).fill(Color.primaryBackground)
                                )
                        )
                }
                .position(midPoint)
                .offset(y: Self.buttonYOffset)
                .opacity(didAppear ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation {
                didAppear = true
            }
        }
    }
}

// MARK: - Constants

extension MovieClientErrorView {
    static let textYOffset: CGFloat = -88
    static let buttonYOffset: CGFloat = 104

    static let buttonCornerRadius: CGFloat = 8
    static let buttonLineWidth: CGFloat = 0.5
    static let buttonPadding: CGFloat = 8
}

// MARK: - Previews

struct MovieClientErrorView_Previews: PreviewProvider {
    static var previews: some View {
        MovieClientErrorView(.network) { }
            .preferredColorScheme(.dark)

        MovieClientErrorView(.requiresUpdate) { }
            .preferredColorScheme(.dark)
    }
}
