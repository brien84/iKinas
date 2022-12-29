//
//  MovieDetailHostingController.swift
//  Cinema
//
//  Created by Marius on 2022-12-29.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

final class MovieDetailHostingController: UIHostingController<MovieDetailView> {
    private let viewStore: ViewStoreOf<MovieDetail>

    init(store: StoreOf<MovieDetail>) {
        self.viewStore = ViewStore(store)
        super.init(rootView: MovieDetailView(store: store))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
