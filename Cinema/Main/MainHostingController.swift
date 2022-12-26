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

private let navigationIdentifier = "showMovieViewController"

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

        navigationController?.navigationBar.setBackgroundImage(color: .primaryBackground)
        view.backgroundColor = .primaryBackground

        viewStore.publisher.selectedMovie
            .sink { movie in
                if let movie {
                    self.performSegue(withIdentifier: navigationIdentifier, sender: movie)
                }
            }.store(in: &self.cancellables)

        viewStore.publisher.selectedShowing
            .sink { showing in
                if let showing {
                    self.performSegue(withIdentifier: navigationIdentifier, sender: showing)
                }
            }.store(in: &self.cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if viewStore.selectedMovie != nil || viewStore.selectedShowing != nil {
            viewStore.send(.deselect)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIView.animate(withDuration: .stdAnimation / 2) { [self] in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == navigationIdentifier {
            guard let vc = segue.destination as? MovieViewController else { return }

            if let movie = sender as? Movie {
                vc.movie = movie
            } else if let showing = sender as? Showing {
                vc.movie = showing.parentMovie
                vc.showing = showing
            } else {
                return
            }
        }
    }
}
