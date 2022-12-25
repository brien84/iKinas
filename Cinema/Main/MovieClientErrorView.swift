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
                    .offset(y: .textYOffset)

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
                        .foregroundColor(.secondaryElement)
                        .padding(.buttonPadding)
                        .background(
                            RoundedRectangle(cornerRadius: .buttonCornerRadius)
                                .strokeBorder(Color.secondaryElement, lineWidth: .buttonLineWidth)
                                .background(
                                    RoundedRectangle(cornerRadius: .buttonCornerRadius).fill(Color.primaryBackground)
                                )
                        )
                }
                .position(midPoint)
                .offset(y: .buttonYOffset)
            }
        }
    }
}

extension CGFloat {
    static let textYOffset: CGFloat = -88
    static let buttonYOffset: CGFloat = 104

    static let buttonCornerRadius: CGFloat = 5
    static let buttonLineWidth: CGFloat = 0.5
    static let buttonPadding: CGFloat = 8
}

struct MovieClientErrorView_Previews: PreviewProvider {
    static var previews: some View {
        MovieClientErrorView(.network) { }
            .preferredColorScheme(.dark)

        MovieClientErrorView(.requiresUpdate) { }
            .preferredColorScheme(.dark)
    }
}
