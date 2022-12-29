//
//  MovieDetailHostingController.swift
//  Cinema
//
//  Created by Marius on 2022-12-29.
//  Copyright © 2022 Marius. All rights reserved.
//

import Combine
import ComposableArchitecture
import SwiftUI

final class MovieDetailHostingController: UIHostingController<MovieDetailView> {
    private var cancellables: Set<AnyCancellable> = []
    private let viewStore: ViewStoreOf<MovieDetail>

    private lazy var leftButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(
                systemName: "chevron.left",
                withConfiguration: UIImage.SymbolConfiguration(scale: .medium)
            ),
            primaryAction: UIAction { _ in }
        )

        return button
    }()

    private lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(
                systemName: "ticket",
                withConfiguration: UIImage.SymbolConfiguration(scale: .medium)
            ),
            primaryAction: UIAction { _ in }
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

        viewStore.publisher.titleViewOverlapPercentage.sink { [self] percentage in
            navigationBar?.setBackgroundImage(color: .primaryBackground, alpha: percentage)

            leftButton.setBackgroundImage(size: .barButtonBackground, color: .primaryBackground, alpha: 1 - percentage)
            rightButton.setBackgroundImage(size: .barButtonBackground, color: .primaryBackground, alpha: 1 - percentage)

            leftButton.imageInsets.left = .maximumBarButtonInset * (1 - percentage)
            rightButton.imageInsets.right = .maximumBarButtonInset * (1 - percentage)

            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryElement.withAlphaComponent(percentage)]
            navigationBar?.standardAppearance.titleTextAttributes = attributes
            navigationBar?.scrollEdgeAppearance?.titleTextAttributes = attributes

            navigationBar?.standardAppearance.titlePositionAdjustment.vertical = .navBarTitleMaximumVerticalOffset * (1 - percentage)
            navigationBar?.scrollEdgeAppearance?.titlePositionAdjustment.vertical = .navBarTitleMaximumVerticalOffset * (1 - percentage)
        }
        .store(in: &self.cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: .stdAnimation / 2) { [self] in
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationItem.hidesBackButton = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.isHidden = true
        cancellables.removeAll()
    }
}

private extension MovieDetailHostingController {
    var navigationBar: UINavigationBar? {
        navigationController?.navigationBar
    }
}

private extension CGFloat {
    static let maximumBarButtonInset: CGFloat = 10
    static let navBarTitleMaximumVerticalOffset: CGFloat = 30
}

private extension CGSize {
    static let barButtonBackground: CGSize = CGSize(width: 33, height: 33)
}

private extension UIBarButtonItem {
    func setBackgroundImage(size: CGSize, color: UIColor, alpha: CGFloat) {
        let image = color.withAlphaComponent(alpha).image(size: size, isEclipse: true)
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
    }
}
