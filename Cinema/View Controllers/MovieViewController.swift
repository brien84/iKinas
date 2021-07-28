//
//  MovieViewController.swift
//  Cinema
//
//  Created by Marius on 2020-07-21.
//  Copyright © 2020 Marius. All rights reserved.
//

import UIKit

final class MovieViewController: UIViewController {
    var movie: Movie?
    var showing: Showing?

    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var poster: NetworkImageView!
    @IBOutlet private weak var movieTitle: CustomFontLabel!
    @IBOutlet private weak var originalTitle: CustomFontLabel!
    @IBOutlet private weak var year: CustomFontLabel!
    @IBOutlet private weak var ageRating: CustomFontLabel!
    @IBOutlet private weak var duration: CustomFontLabel!
    @IBOutlet private weak var plot: CustomFontLabel!
    @IBOutlet private weak var venueImage: VenueImageView!
    @IBOutlet private weak var time: CustomFontLabel!
    @IBOutlet private weak var genresStackView: UIStackView!

    @IBOutlet private weak var titleContainer: UIView!
    @IBOutlet private weak var detailsContainer: UIView!

    @IBOutlet private weak var posterHeight: NSLayoutConstraint!
    @IBOutlet private weak var posterTopToSuperview: NSLayoutConstraint!
    @IBOutlet private weak var posterBottomToDetailsTop: NSLayoutConstraint!
    @IBOutlet private weak var detailsBottomToSuperview: NSLayoutConstraint!
    @IBOutlet private weak var showingContainerIsCollapsed: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        navigationController?.delegate = self

        // Set `backgroundColor` in code, because of iOS12 bug, where when
        // a custom color is selected in storyboard it cannot be changed.
        view.backgroundColor = .secondaryBackground

        setLabels()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        showingContainerIsCollapsed.isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        scrollView.delegate?.scrollViewDidScroll?(scrollView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: .stdAnimation / 2) { [self] in
            navigationController?.setNavigationBarHidden(false, animated: true)

            if showing != nil {
                showingContainerIsCollapsed.isActive = false
                view.layoutIfNeeded()
            }
        }
    }

    @IBAction private func backButtonDidTap(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)

        // Resets `navigationBar` appearance.
        navigationBar?.setTitleVerticalPositionAdjustment(0, for: .default)
        navigationBar?.setBackgroundImage(color: .secondaryBackground)
    }

    @IBAction private func showingsButtonDidTap(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: .stdAnimation) { [self] in
            scrollView.setContentOffset(.zero, animated: false)
        } completion: { [self] _ in
            performSegue(withIdentifier: "showShowingsVC", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showShowingsVC" {
            guard let vc = segue.destination as? ShowingsViewController else { return }

            // Copy current back button appearance.
            guard let leftButton = navigationItem.leftBarButtonItem else { return }
            guard let leftButtonImage = leftButton.backgroundImage(for: .normal, barMetrics: .default) else { return }
            guard let vcLeftButton = vc.navigationItem.leftBarButtonItem else { return }
            vcLeftButton.setBackgroundImage(size: leftButtonImage.size, color: .secondaryBackground, alpha: 1.0)
            vcLeftButton.imageInsets = leftButton.imageInsets

            vc.movie = movie
        }

        if segue.identifier == "showWebVC" {
            guard let vc = segue.destination as? WebViewController else { return }
            guard let showing = showing else { return }
            vc.url = showing.url
        }
    }

    private func setLabels() {
        navigationItem.title = movie?.title

        poster.url = movie?.poster
        movieTitle.text = movie?.title
        originalTitle.text = movie?.originalTitle
        year.text = movie?.year
        ageRating.text = movie?.ageRating
        duration.text = movie?.duration
        plot.text = movie?.plot

        genresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        movie?.genres.forEach { genre in
            genresStackView.addArrangedSubview(createGenreButton(with: genre))
        }

        venueImage.venue = showing?.venue
        time.text = showing?.date.asString(.timeOfDay)
    }

    private func createGenreButton(with title: String) -> UIButton {
        let button = UIButton()
        button.isUserInteractionEnabled = false

        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .caption2)
        button.setTitleColor(.primaryElement, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = UIColor.primaryElement.cgColor

        return button
    }
}

extension MovieViewController: UIScrollViewDelegate {
    private var navigationBar: UINavigationBar? {
        navigationController?.navigationBar
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // If `navigationController` is nil, `MovieViewController` is in transition.
        if navigationController != nil {
            // scroll down positive, up negative
            let offset = scrollView.contentOffset.y

            handleScrollDown(offset)
            adjustNavigationBarAlpha(with: offset)
            adjustNavigationBarTitle(with: offset)
            adjustNavigationBarButtons(with: offset)
            adjustPosterViewAlpha(with: offset)
        }
    }

    /// Streches `poster` and reduces alpha of `titleContainer` when scrolling downwards.
    private func handleScrollDown(_ offset: CGFloat) {
        // Convert offset to positive number for clearer calculations.
        let offset = -offset

        // If scrolling upwards.
        if 0 >= offset {
            posterHeight.constant = 0
            posterTopToSuperview.constant = 0
            posterBottomToDetailsTop.constant = 0
            detailsBottomToSuperview.constant = 0

            titleContainer.alpha = 1.0
            return
        }

        let multi = 1 + posterBottomToDetailsTop.multiplier
        let totalOverlap = detailsContainer.frame.minY.distance(to: poster.frame.maxY) / multi
        let currentOverlap = totalOverlap + posterBottomToDetailsTop.constant / multi

        // Lowers `detailsContainer` until it no longer overlaps `poster`.
        if offset > 0, currentOverlap >= offset {
            posterHeight.constant = 0
            posterTopToSuperview.constant = offset
            posterBottomToDetailsTop.constant = offset * multi
            detailsBottomToSuperview.constant = -offset

            titleContainer.alpha = 1.0 - offset / currentOverlap
        }

        // Streches `poster`.
        if offset > currentOverlap {
            posterHeight.constant = offset - currentOverlap
            posterTopToSuperview.constant = offset
            posterBottomToDetailsTop.constant = currentOverlap * multi
            detailsBottomToSuperview.constant = -currentOverlap

            titleContainer.alpha = 0.0
        }
    }

    private func adjustNavigationBarAlpha(with offset: CGFloat) {
        guard let navigationBar = navigationBar else { return }

        let totalDistance = navigationBar.frame.maxY.distance(to: titleContainer.frame.minY)
        let currentDistance = totalDistance - offset

        let height = titleContainer.frame.height

        if 0 > currentDistance {
            let alpha = (1 - (height + currentDistance) / height)
            navigationBar.setBackgroundImage(color: .secondaryBackground, alpha: alpha)
        } else {
            navigationBar.setBackgroundImage(color: .secondaryBackground, alpha: 0.0)
        }
    }

    /// Makes `navigationBar` title appear as `titleContainer` goes under `navigationBar`.
    private func adjustNavigationBarTitle(with offset: CGFloat) {
        guard let navigationBar = navigationBar else { return }

        let totalDistance = navigationBar.frame.maxY.distance(to: titleContainer.frame.maxY)
        let currentDistance = totalDistance - offset

        // Height is halved, because title is adjusted up until `navigationBar` vertical center.
        let navBarHeight = navigationBar.frame.height / 2

        if 0 > currentDistance {
            navigationBar.setTitleAlpha(1.0)
            navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
            return
        }

        if currentDistance > navBarHeight {
            navigationBar.setTitleAlpha(0.0)
        }

        if navBarHeight > currentDistance {
            navigationBar.setTitleAlpha(1.0 - currentDistance / navBarHeight)
            navigationBar.setTitleVerticalPositionAdjustment(currentDistance, for: .default)
        }
    }

    private func adjustNavigationBarButtons(with offset: CGFloat) {
        guard let navigationBar = navigationBar else { return }
        guard let leftButton = navigationItem.leftBarButtonItem else { return }
        guard let rightButton = navigationItem.rightBarButtonItem else { return }

        let totalDistance = navigationBar.frame.maxY.distance(to: titleContainer.frame.minY)
        let currentDistance = totalDistance - offset

        let inset = navigationBar.frame.width * 0.02
        let height = navigationBar.frame.height * 0.8
        let size = CGSize(width: height, height: height)

        if currentDistance > navigationBar.frame.height {
            leftButton.setBackgroundImage(size: size, color: .secondaryBackground, alpha: 1.0)
            leftButton.imageInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)

            rightButton.setBackgroundImage(size: size, color: .secondaryBackground, alpha: 1.0)
            rightButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset)
        }

        if navigationBar.frame.height >= currentDistance {
            let percentage = currentDistance / navigationBar.frame.height

            leftButton.setBackgroundImage(size: size, color: .secondaryBackground, alpha: percentage)
            leftButton.imageInsets = UIEdgeInsets(top: 0, left: inset * percentage, bottom: 0, right: 0)

            rightButton.setBackgroundImage(size: size, color: .secondaryBackground, alpha: percentage)
            rightButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset * percentage)
        }

        if 0 > currentDistance {
            leftButton.setBackgroundImage(size: size, color: .secondaryBackground, alpha: 0.0)
            leftButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

            rightButton.setBackgroundImage(size: size, color: .secondaryBackground, alpha: 0.0)
            rightButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    private func adjustPosterViewAlpha(with offset: CGFloat) {
        guard let navigationBar = navigationBar else { return }

        if offset > 0 {
            let totalDistance = navigationBar.frame.maxY.distance(to: titleContainer.frame.minY)
            let currentDistance = totalDistance - offset
            poster.alpha = currentDistance / totalDistance
        } else {
            poster.alpha = 1.0
        }
    }
}

extension MovieViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if type(of: toVC) == MovieViewController.self || type(of: toVC) == ShowingsViewController.self {
            if operation == .push {
                return ShowingsViewTransitionAnimator(isPushing: true)
            }

            if operation == .pop {
                return ShowingsViewTransitionAnimator(isPushing: false)
            }
        }

        return nil
    }
}

private extension UINavigationBar {
    func setTitleAlpha(_ alpha: CGFloat) {
        self.titleTextAttributes = [.foregroundColor: UIColor.primaryElement.withAlphaComponent(alpha),
                                    .font: Fonts.getFont(.navigationBar)]
    }
}

private extension UIBarButtonItem {
    func setBackgroundImage(size: CGSize, color: UIColor, alpha: CGFloat) {
        let image = color.withAlphaComponent(alpha).image(size: size, isEclipse: true)
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
    }
}
