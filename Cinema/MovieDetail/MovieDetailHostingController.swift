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
            primaryAction: UIAction { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
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

        navigationController?.interactivePopGestureRecognizer?.delegate = self

        navigationItem.title = viewStore.movie.title
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton

        viewStore.publisher.titleViewOverlapPercentage.sink { [self] percentage in
            // Sets `navigationBar` opacity.
            navigationBar?.setBackgroundImage(color: .primaryBackground, alpha: percentage)

            // Sets the background opacity of the bar buttons in the `navigationItem`.
            leftButton.setBackgroundImage(size: .barButtonBackground, color: .primaryBackground, alpha: 1 - percentage)
            rightButton.setBackgroundImage(size: .barButtonBackground, color: .primaryBackground, alpha: 1 - percentage)

            // Sets the horizontal inset of the bar buttons in the `navigationItem`.
            leftButton.imageInsets.left = .maximumBarButtonInset * (1 - percentage)
            rightButton.imageInsets.right = .maximumBarButtonInset * (1 - percentage)

            // Sets `navigationBar` title opacity.
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryElement.withAlphaComponent(percentage)]
            navigationBar?.standardAppearance.titleTextAttributes = attributes
            navigationBar?.scrollEdgeAppearance?.titleTextAttributes = attributes

            // Sets `navigationBar` title vertical offset.
            navigationBar?.standardAppearance.titlePositionAdjustment.vertical = .navBarTitleMaximumVerticalOffset * (1 - percentage)
            navigationBar?.scrollEdgeAppearance?.titlePositionAdjustment.vertical = .navBarTitleMaximumVerticalOffset * (1 - percentage)
        }
        .store(in: &self.cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async { [self] in
            navigationItem.hidesBackButton = true
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        cancellables.removeAll()
    }
}

private extension MovieDetailHostingController {
    var navigationBar: UINavigationBar? {
        navigationController?.navigationBar
    }
}

extension MovieDetailHostingController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Smoothly hides `navigationBar` just before `interactivePopGesture` begins.
        UIView.animate(withDuration: .hideNavigationBarDuration) { [self] in
            navigationController?.setNavigationBarHidden(true, animated: true)
        }

        return true
    }
}

private extension CGFloat {
    static let maximumBarButtonInset: CGFloat = 10
    static let navBarTitleMaximumVerticalOffset: CGFloat = 30
}

private extension CGSize {
    static let barButtonBackground: CGSize = CGSize(width: 40, height: 40)
}

private extension TimeInterval {
    static let hideNavigationBarDuration: TimeInterval = 0.15
}

private extension UIBarButtonItem {
    func setBackgroundImage(size: CGSize, color: UIColor, alpha: CGFloat) {
        let image = color.withAlphaComponent(alpha).image(size: size, isEclipse: true)
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
    }
}
