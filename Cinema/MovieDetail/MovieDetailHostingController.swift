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
    private var lastTitleViewOverlapPercentage: CGFloat = 0
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
            primaryAction: UIAction { [weak self] _ in
                self?.viewStore.send(.setShowingDetail(isPresented: true))
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

        viewStore.publisher.openedURL
            .delay(for: .milliseconds(10), scheduler: RunLoop.main)
            .sink { [self] url in
            if let url {
                let vc = WebViewController(url: url)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        .store(in: &self.cancellables)

        viewStore.publisher.titleViewOverlapPercentage.sink { [self] percentage in
            lastTitleViewOverlapPercentage = percentage
            updateNavigationBarAppearance(overlap: percentage)
        }
        .store(in: &self.cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateNavigationBarAppearance(overlap: lastTitleViewOverlapPercentage)

        if viewStore.openedURL != nil {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        updateNavigationBarAppearance(overlap: 1)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if viewStore.openedURL == nil {
            cancellables.removeAll()
        }
    }

    private func updateNavigationBarAppearance(overlap percentage: CGFloat) {
        // Sets `navigationBar` opacity.
        navigationBar?.setBackgroundImage(color: .primaryBackground, alpha: percentage)

        // Sets the background opacity of the bar buttons in the `navigationItem`.
        leftButton.setBackgroundImage(size: Self.barButtonBackgroundSize, color: .primaryBackground, alpha: 1 - percentage)
        rightButton.setBackgroundImage(size: Self.barButtonBackgroundSize, color: .primaryBackground, alpha: 1 - percentage)

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

private extension UIBarButtonItem {
    func setBackgroundImage(size: CGSize, color: UIColor, alpha: CGFloat) {
        let image = color.withAlphaComponent(alpha).renderEllipseImage(size: size)
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
    }
}

extension UINavigationBar {
    func setBackgroundImage(color: UIColor, alpha: CGFloat = 1.0) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        // If `alpha` is equal or higher than 1.0 `UINavigationBar`
        // will apply a system-defined alpha value.
        let alpha = alpha >= 0.99 ? 0.99 : alpha
        let color = color.withAlphaComponent(alpha)

        // `UINavigationBar` will size the image to fill.
        appearance.backgroundImage = color.renderRectImage(size: .init(width: 1, height: 1))

        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
    }
}

// MARK: - Constants

private extension MovieDetailHostingController {
    static let barButtonBackgroundSize: CGSize = CGSize(width: 36, height: 36)
    static let maximumBarButtonInset: CGFloat = 10
    static let navBarTitleMaximumVerticalOffset: CGFloat = 30
}
