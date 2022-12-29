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

        viewStore.publisher.selectedMovie
            .sink { movie in
                if let movie {
                    let store = Store(initialState: MovieDetail.State(movie: movie, showing: nil), reducer: MovieDetail())
                    let vc = MovieDetailHostingController(store: store)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }.store(in: &self.cancellables)

        viewStore.publisher.selectedShowing
            .sink { showing in
                if let showing, let movie = showing.parentMovie {
                    let store = Store(initialState: MovieDetail.State(movie: movie, showing: showing), reducer: MovieDetail())
                    let vc = MovieDetailHostingController(store: store)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }.store(in: &self.cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async { [self] in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

        if viewStore.selectedMovie != nil || viewStore.selectedShowing != nil {
            viewStore.send(.deselect)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.main.async { [self] in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
}
