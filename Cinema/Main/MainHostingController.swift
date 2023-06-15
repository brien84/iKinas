//
//  MainHostingController.swift
//  Cinema
//
//  Created by Marius on 2022-12-20.
//  Copyright © 2022 Marius. All rights reserved.
//

import Combine
import ComposableArchitecture
import SwiftUI

final class MainHostingController: UIHostingController<MainView> {
    private var cancellables: Set<AnyCancellable> = []
    private let viewStore: ViewStoreOf<Main>

    @Dependency(\.userDefaults) var userDefaults

    required init?(coder aDecoder: NSCoder) {
        let store = Store(initialState: Main.State(), reducer: Main())
        self.viewStore = ViewStore(store)

        super.init(
            coder: aDecoder,
            rootView: MainView(store: store)
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .primaryBackground

        if userDefaults.isFirstLaunch() {
            viewStore.send(.setNavigationToSettings(isActive: true))
        } else {
            viewStore.send(.fetchMovies, animation: .default)
        }

        viewStore.publisher.movieDetail
            .sink { state in
                guard let state else { return }
                let store = Store(initialState: state, reducer: MovieDetail())
                let vc = MovieDetailHostingController(store: store)
                self.navigationController?.pushViewController(vc, animated: true)
            }.store(in: &self.cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async { [self] in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

        if viewStore.movieDetail != nil {
            viewStore.send(.setNavigationToMovieDetail(isActive: false))
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.main.async { [self] in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
}
