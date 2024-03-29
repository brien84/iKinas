//
//  LoadingView.swift
//  Cinema
//
//  Created by Marius on 2022-12-25.
//  Copyright © 2022 Marius. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    @State private var image = 0

    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            Image("LoadingAnimation/\(image)")
                .onReceive(timer) { _ in
                    if image == 20 {
                        image = 0
                    } else {
                        image += 1
                    }
                }
        }
    }
}

// MARK: - Previews

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .preferredColorScheme(.dark)
    }
}
