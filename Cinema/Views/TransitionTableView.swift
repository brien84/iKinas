//
//  TransitionTableView.swift
//  Cinema
//
//  Created by Marius on 2020-12-19.
//  Copyright © 2020 Marius. All rights reserved.
//

import UIKit

protocol TransitionTableViewDelegate: AnyObject {
    func prepareForTransition(animated isAnimated: Bool, completion: (() -> Void)?)
}

final class TransitionTableView: UITableView {
    @IBOutlet private weak var headerMoviesLabel: CustomFontLabel!
    @IBOutlet private weak var headerContainerView: UIView!
    @IBOutlet private weak var headerShowingsLabel: CustomFontLabel!

    weak var transitionDelegate: TransitionTableViewDelegate?

    private var tableSnapshot = UIView()
    private var containerSnapshot = UIView()
    private var moviesLabelSnapshot = UIView()
    private var showingsLabelSnapshot = UIView()

    /// A view which covers `tableView` and performs the transition.
    private lazy var transitionView: UIView = {
        let view = UIView()
        view.backgroundColor = backgroundColor
        return view
    }()

    /// Returns true if`tableHeaderView` is fully under safe area.
    private var isTableHeaderViewVisible: Bool {
        guard let header = tableHeaderView else { return false }
        let distance = safeAreaInsets.top.distance(to: header.frame.maxY)
        return distance >= contentOffset.y
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        tableHeaderView?.frame.size = CGSize(width: frame.width, height: frame.width * 1.25)
    }

    private func setupTransitionView() {
        transitionView.subviews.forEach { $0.removeFromSuperview() }
        transitionView.removeFromSuperview()

        tableSnapshot = snapshotTableView()
        containerSnapshot = snapshotHeaderContainerView()
        moviesLabelSnapshot = snapshotHeaderMoviesLabel()
        showingsLabelSnapshot = snapshotHeaderShowingsLabel()

        transitionView.addSubview(tableSnapshot)
        transitionView.addSubview(containerSnapshot)
        transitionView.addSubview(moviesLabelSnapshot)
        transitionView.addSubview(showingsLabelSnapshot)

        if frame.height > contentSize.height {
            transitionView.frame = CGRect(origin: frame.origin, size: frame.size)
        } else {
            transitionView.frame = CGRect(origin: frame.origin, size: contentSize)
        }

        addSubview(transitionView)
    }

    func prepareTransition(completion: @escaping () -> Void) {
        alignToSafeArea { [self] in
            transitionDelegate?.prepareForTransition(animated: isTableHeaderViewVisible) { [self] in
                setupTransitionView()

                let offset = contentOffset.y
                scrollToTop()
                transitionView.frame.origin.y = -offset + bounds.origin.y

                completion()
            }
        }
    }

    func beginTransition(completion: @escaping () -> Void) {
        UIView.animate(withDuration: .stdAnimation) { [self] in
            tableSnapshot.frame.origin.y += tableSnapshot.frame.height
            containerSnapshot.frame.origin.x += containerSnapshot.frame.width
            moviesLabelSnapshot.alpha = 0
            showingsLabelSnapshot.alpha = 0
        } completion: { _ in
            completion()
        }
    }

    private func prepareEndTransition() {
        let overlay = UIView(frame: frame)
        overlay.backgroundColor = transitionView.backgroundColor
        superview?.addSubview(overlay)

        setupTransitionView()

        overlay.removeFromSuperview()

        tableSnapshot.frame.origin.y += tableSnapshot.frame.height
        containerSnapshot.frame.origin.x += containerSnapshot.frame.width
        moviesLabelSnapshot.alpha = 0.0
        showingsLabelSnapshot.alpha = 0.0
    }

    func endTransition(completion: @escaping () -> Void) {
        prepareEndTransition()

        UIView.animate(withDuration: .stdAnimation) { [self] in
            tableSnapshot.frame.origin.y -= tableSnapshot.frame.height
            containerSnapshot.frame.origin.x -= containerSnapshot.frame.width
            moviesLabelSnapshot.alpha = 1.0
            showingsLabelSnapshot.alpha = 1.0
        } completion: { [self] _ in
            transitionView.removeFromSuperview()
            completion()
        }
    }

    func scrollToTop() {
        if contentOffset.y > -safeAreaInsets.top {
            setContentOffset(CGPoint(x: 0, y: -safeAreaInsets.top), animated: false)
            layoutIfNeeded()
        }
    }

    /// Aligns first visible cell to safe area, so it doesn't get cut off during transition.
    private func alignToSafeArea(completion: @escaping () -> Void) {
        if isTableHeaderViewVisible == false, visibleCells.count > 1 {
            let cellToScrollTo: UITableViewCell

            let firstCell = visibleCells[0]
            let secondCell = visibleCells[1]
            let distance = safeAreaInsets.top.distance(to: firstCell.frame.maxY)

            // If first cell is not fully under safe area...
            if distance >= contentOffset.y {
                cellToScrollTo = firstCell
            } else {
                cellToScrollTo = secondCell
            }

            UIView.animate(withDuration: .stdAnimation) { [self] in
                scrollRectToVisible(cellToScrollTo.frame, animated: false)
                layoutIfNeeded()
            } completion: { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    // MARK: - Snapshots

    private func snapshotTableView() -> UIView {
        let rect: CGRect

        if isTableHeaderViewVisible {
            guard let header = tableHeaderView else { return UIView() }
            let origin = CGPoint(x: header.bounds.minX, y: header.bounds.maxY)
            let size = CGSize(width: frame.width, height: bounds.maxY - header.bounds.maxY)
            rect = CGRect(origin: origin, size: size)
        } else {
            let origin = CGPoint(x: bounds.minX, y: bounds.minY + safeAreaInsets.top)
            let size = CGSize(width: frame.width, height: frame.height - safeAreaInsets.top)
            rect = CGRect(origin: origin, size: size)
        }

        if let snapshot = resizableSnapshotView(from: rect, afterScreenUpdates: true, withCapInsets: .zero) {
            snapshot.frame.origin.y = bounds.maxY - snapshot.frame.height
            return snapshot
        } else {
            return UIView()
        }
    }

    private func snapshotHeaderContainerView() -> UIView {
        if let snapshot = headerContainerView.snapshotView(afterScreenUpdates: true) {
            snapshot.frame.origin = headerContainerView.frame.origin
            return snapshot
        } else {
            return UIView()
        }
    }

    private func snapshotHeaderMoviesLabel() -> UIView {
        if let snapshot = headerMoviesLabel.snapshotView(afterScreenUpdates: true) {
            snapshot.frame.origin = headerMoviesLabel.frame.origin
            return snapshot
        } else {
            return UIView()
        }
    }

    private func snapshotHeaderShowingsLabel() -> UIView {
        if let snapshot = headerShowingsLabel.snapshotView(afterScreenUpdates: true) {
            snapshot.frame.origin = headerShowingsLabel.frame.origin
            return snapshot
        } else {
            return UIView()
        }
    }
}
