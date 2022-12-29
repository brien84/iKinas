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

    private lazy var leftButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)),
            primaryAction: UIAction { _ in print("right button") }
        )

        return button
    }()

    private lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "ticket", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)),
            primaryAction: UIAction { _ in print("left button") }
        )

        return button
    }()

    init(store: StoreOf<MovieDetail>) {
        self.viewStore = ViewStore(store)
        super.init(rootView: MovieDetailView(store: store))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: .stdAnimation / 2) { [self] in
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationItem.hidesBackButton = true
        }
    }
}
