//
//  GreetingView.swift
//  Cinema
//
//  Created by Marius on 2023-10-01.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

struct GreetingView: View {
    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5...11:
            return "Labas rytas!"
        case 12...17:
            return "Laba diena!"
        case 0...4, 18...23:
            return "Labas vakaras!"
        default:
            return "Sveiki!"
        }
    }

    var body: some View {
        VStack {
            Text(greeting)
                .font(.largeTitle.bold())
                .foregroundColor(.primaryElement)
        }
    }
}

struct GreetingView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingView()
            .preferredColorScheme(.dark)
    }
}
