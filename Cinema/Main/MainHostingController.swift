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

    @Dependency(\.apiClient) var apiClient
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
        
        if _XCTIsTesting { return }

        view.backgroundColor = .primaryBackground

        userDefaults.setAppVersion()

        if userDefaults.isFirstLaunch() {
            viewStore.send(.setNavigationToSettings(isActive: true))
        } else {
            viewStore.send(.fetch, animation: .default)
        }

        viewStore.publisher.showingInfo
            .sink { [self] state in
                guard var state else { return }

                var similar = apiClient.getShowings().filter(similarTo: state.showing)
                similar.sort(by: .title)
                state.similar = similar

                let vc = ShowingInfoHostingController(state: state)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &self.cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async { [self] in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

        if viewStore.showingInfo != nil {
            viewStore.send(.setNavigationToShowingInfo(isActive: false))
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.main.async { [self] in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
}
