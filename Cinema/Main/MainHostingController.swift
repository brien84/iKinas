//
//  MainHostingController.swift
//  Cinema
//
//  Created by Marius on 2022-12-20.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

final class MainHostingController: UIHostingController<MainView> {
    private let store: StoreOf<Main>

    required init?(coder aDecoder: NSCoder) {
        let store = Store(initialState: Main.State(), reducer: Main())
        self.store = store

        super.init(
            coder: aDecoder,
            rootView: MainView(store: store)
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondaryBackground
    }
}
