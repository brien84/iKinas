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

            VStack(spacing: .zero) {
                Text("Error!")
            }
        }
    }
}

struct MovieClientErrorView_Previews: PreviewProvider {
    static var previews: some View {
        MovieClientErrorView(.network) { }
            .preferredColorScheme(.dark)

        MovieClientErrorView(.requiresUpdate) { }
            .preferredColorScheme(.dark)
    }
}
