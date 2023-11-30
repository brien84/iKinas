//
//  SectionLabelView.swift
//  Cinema
//
//  Created by Marius on 2023-11-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import SwiftUI

struct SectionLabelView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.title.bold())
            .foregroundColor(.primaryElement)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

#Preview {
    SectionLabelView(text: "Preview")
        .background(Color.primaryBackground)
}
