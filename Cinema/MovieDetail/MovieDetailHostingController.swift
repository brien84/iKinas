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
    private var currentTitleViewOverlapPercentage: CGFloat = 0
    private var isInteractivePopInProgress = false {
        didSet {
            if isInteractivePopInProgress {
                viewStore.send(.toggleScrollDisabled(true))
            } else {
                viewStore.send(.toggleScrollDisabled(false))
            }
        }
    }

    private lazy var leftButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(
                systemName: "chevron.left",
                withConfiguration: UIImage.SymbolConfiguration(scale: .medium)
            ),
            primaryAction: UIAction { [weak self] _ in
                if self?.viewStore.showingDetail == nil {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.viewStore.send(.toggleShowingDetail, animation: Self.toggleShowingDetailAnimation)
                    self?.hideRightBarButton(false)
                }
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
            primaryAction: UIAction { [weak self] _ in
                if self?.viewStore.showingDetail == nil {
                    self?.viewStore.send(.toggleShowingDetail, animation: Self.toggleShowingDetailAnimation)
                    self?.hideRightBarButton(true)
                }
            }
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

        viewStore.publisher.openedURL.sink { [self] url in
            if let url {
                let vc = WebViewController(url: url)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        .store(in: &self.cancellables)

        viewStore.publisher.titleViewOverlapPercentage.sink { [self] percentage in
            currentTitleViewOverlapPercentage = percentage

            // Sets `navigationBar` opacity.
            navigationBar?.setBackgroundImage(color: .primaryBackground, alpha: percentage)

            // Sets the background opacity of the bar buttons in the `navigationItem`.
            if viewStore.showingDetail == nil {
                leftButton.setBackgroundImage(size: Self.barButtonBackground, color: .primaryBackground, alpha: 1 - percentage)
                rightButton.setBackgroundImage(size: Self.barButtonBackground, color: .primaryBackground, alpha: 1 - percentage)
            }

            // Sets the horizontal inset of the bar buttons in the `navigationItem`.
            leftButton.imageInsets.left = Self.maximumBarButtonInset * (1 - percentage)
            rightButton.imageInsets.right = Self.maximumBarButtonInset * (1 - percentage)

            // Sets `navigationBar` title opacity.
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryElement.withAlphaComponent(percentage)]
            navigationBar?.standardAppearance.titleTextAttributes = attributes
            navigationBar?.scrollEdgeAppearance?.titleTextAttributes = attributes

            // Sets `navigationBar` title vertical offset.
            navigationBar?.standardAppearance.titlePositionAdjustment.vertical = Self.navBarTitleMaximumVerticalOffset * (1 - percentage)
            navigationBar?.scrollEdgeAppearance?.titlePositionAdjustment.vertical = Self.navBarTitleMaximumVerticalOffset * (1 - percentage)
        }
        .store(in: &self.cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if viewStore.openedURL != nil {
            viewStore.send(.updateTitleViewOverlap(percentage: currentTitleViewOverlapPercentage + .leastNonzeroMagnitude))
            viewStore.send(.openURL(nil))
        }

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isInteractivePopInProgress = false

        DispatchQueue.main.async { [self] in
            navigationItem.hidesBackButton = true
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if viewStore.openedURL == nil {
            cancellables.removeAll()
        }
    }

    private func hideRightBarButton(_ isHidden: Bool) {
        if isHidden {
            rightButton.tintColor = .clear
            rightButton.setBackgroundImage(size: Self.barButtonBackground, color: .primaryBackground, alpha: .zero)
        } else {
            rightButton.tintColor = .primaryElement
            rightButton.setBackgroundImage(size: Self.barButtonBackground, color: .primaryBackground, alpha: 1 - currentTitleViewOverlapPercentage)
        }
    }
}

private extension MovieDetailHostingController {
    var navigationBar: UINavigationBar? {
        navigationController?.navigationBar
    }
}

extension MovieDetailHostingController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        DispatchQueue.main.async {
            self.isInteractivePopInProgress = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }

        return true
    }
}

// MARK: - Constants

private extension MovieDetailHostingController {
    static let barButtonBackground: CGSize = CGSize(width: 36, height: 36)
    static let maximumBarButtonInset: CGFloat = 10
    static let navBarTitleMaximumVerticalOffset: CGFloat = 30
    static let toggleShowingDetailAnimation: Animation = .spring(response: 0.4, dampingFraction: 1.0)
}

private extension UIBarButtonItem {
    func setBackgroundImage(size: CGSize, color: UIColor, alpha: CGFloat) {
        let image = color.withAlphaComponent(alpha).image(size: size, isEclipse: true)
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
    }
}
