//
//  NetworkErrorView.swift
//  Cinema
//
//  Created by Marius on 2022-12-25.
//  Copyright © 2022 Marius. All rights reserved.
//

import SwiftUI

struct NetworkErrorView: View {

    var body: some View {
        ZStack {
            Color.primaryBackground

            VStack(spacing: .zero) {
                Text("Error!")
            }

        }.ignoresSafeArea()
    }
}

struct NetworkErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkErrorView()
            .preferredColorScheme(.dark)
    }
}
