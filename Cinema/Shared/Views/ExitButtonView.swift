//
//  ExitButtonView.swift
//  Cinema
//
//  Created by Marius on 2022-12-04.
//  Copyright © 2022 Marius. All rights reserved.
//

import SwiftUI

struct ExitButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(
            action: {
                action()
            },
            label: {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Self.width)
                    .font(.title3.bold())
                    .padding(Self.padding)
                    .foregroundColor(.secondaryElement)
                    .background(
                        Circle()
                            .fill(Color.secondaryBackground)
                    )
            }
        )
    }
}

// MARK: - Constants

private extension ExitButtonView {
    static let width: CGFloat = 12
    static let padding: CGFloat = 10
}

// MARK: - Previews

struct ExitButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white

            ExitButtonView { }
        }
    }
}
