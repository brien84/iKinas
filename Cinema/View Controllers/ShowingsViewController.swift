//
//  ShowingsViewController.swift
//  Cinema
//
//  Created by Marius on 2021-01-23.
//  Copyright © 2021 Marius. All rights reserved.
//

import UIKit

private let containerViewReuseID = "showingsViewContainerCell"
private let datesViewReuseID = "showingsViewDateCell"
private let timesViewReuseID = "showingsViewTimeCell"

final class ShowingsViewController: UIViewController {
    var movie: Movie?
    private let dates = DateTracker.dates

    @IBOutlet private weak var poster: NetworkImageView!
    @IBOutlet private weak var containersView: UICollectionView!
    @IBOutlet private weak var datesView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.setBackgroundImage(color: .secondaryBackground, alpha: 0)

        poster.url = movie?.poster
    }

    private func getShowings(on date: Date) -> [Showing] {
        guard let movie = movie else { return [] }
        let showings = movie.showings.filter { $0.isShown(on: date) }
        return showings.sorted()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showWebVC" else { return }
        guard let vc = segue.destination as? WebViewController else { return }
        guard let url = sender as? URL else { return }
        vc.url = url
    }

    @IBAction private func backButtonDidTap(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

extension ShowingsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == containersView || collectionView == datesView {
            return dates.count
        }

        // `ShowingsViewContainerCell` `timesView` setup.
        guard let containerView = collectionView.superview?.superview else { return 0 }

        if getShowings(on: dates[containerView.tag]).count == 0 {
            let loadingView = LoadingView()
            loadingView.show(.noShowings, animated: false)
            collectionView.backgroundView = loadingView
        }

        return getShowings(on: dates[containerView.tag]).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == containersView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: containerViewReuseID, for: indexPath)
            // swiftlint:disable:next force_cast
            let containerCell = cell as! ShowingsViewContainerCell
            containerCell.tag = indexPath.row
            containerCell.timesView.dataSource = self
            containerCell.timesView.delegate = self

            return containerCell
        }

        if collectionView == datesView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: datesViewReuseID, for: indexPath)
            // swiftlint:disable:next force_cast
            let dateCell = cell as! ShowingsViewDateCell
            dateCell.date.text = dates[indexPath.row].asString(.monthAndDay)

            // Highlights first cell when the view is loaded, later cell highlighting
            // is handled in `datesViewScrollToItem(at:)` method.
            if indexPath == datesViewCenterIndexPath {
                dateCell.isLabelHighlighted = true
            }

            return dateCell
        }

        // `ShowingsViewContainerCell` `timesView` setup.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timesViewReuseID, for: indexPath)
        // swiftlint:disable:next force_cast
        let timeCell = cell as! ShowingsViewTimeCell

        guard let containerView = collectionView.superview?.superview else { return timeCell }
        let showings = getShowings(on: dates[containerView.tag])
        timeCell.time.text = showings[indexPath.row].date.asString(.timeOfDay)
        timeCell.venueImage.venue = showings[indexPath.row].venue
        timeCell.is3D = showings[indexPath.row].is3D

        return timeCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView != containersView || collectionView != datesView else { return }
        guard let containerView = collectionView.superview?.superview else { return }
        let showings = getShowings(on: dates[containerView.tag])
        let url = showings[indexPath.row].url

        performSegue(withIdentifier: "showWebVC", sender: url)
    }
}

extension ShowingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case containersView:
            return collectionView.frame.size
        case datesView:
            return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.height)
        default:
            let layout = collectionViewLayout as? UICollectionViewFlowLayout
            let leftInset = layout?.sectionInset.left ?? 0
            let rightInset = layout?.sectionInset.right ?? 0
            return CGSize(width: collectionView.frame.width / 2 - leftInset - rightInset, height: collectionView.frame.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case containersView:
            return .zero
        case datesView:
            let width = (collectionView.frame.width / 2) - (collectionView.frame.width / 3 / 2)
            return UIEdgeInsets(top: 0, left: width, bottom: 0, right: width)
        default:
            guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
            guard let containerView = collectionView.superview?.superview else { return .zero }
            let showings = getShowings(on: dates[containerView.tag])

            if showings.count == 1 {
                return UIEdgeInsets(top: layout.sectionInset.top, left: layout.sectionInset.left,
                                    bottom: layout.sectionInset.bottom, right: collectionView.frame.width / 2)
            } else {
                return layout.sectionInset
            }
        }
    }
}

extension ShowingsViewController: UIScrollViewDelegate {
    private var containersViewCenterIndexPath: IndexPath? {
        let point = CGPoint(x: containersView.bounds.midX, y: containersView.bounds.midY)
        return containersView.indexPathForItem(at: point)
    }

    private var datesViewCenterIndexPath: IndexPath? {
        let point = CGPoint(x: datesView.bounds.midX, y: datesView.bounds.midY)
        return datesView.indexPathForItem(at: point)
    }

    private func datesViewScrollToItem(at indexPath: IndexPath) {
        guard let cell = datesView.cellForItem(at: indexPath) as? ShowingsViewDateCell else { return }

        datesView.visibleCells.forEach {
            if let visibleCell = $0 as? ShowingsViewDateCell {
                visibleCell.isLabelHighlighted = false
            }
        }

        cell.isLabelHighlighted = true

        datesView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView == containersView || scrollView == datesView else { return }
        guard let datesRow = datesViewCenterIndexPath?.row else { return }
        guard let containerRow = containersViewCenterIndexPath?.row else { return }

        if datesRow != containerRow {
            if scrollView == containersView {
                datesViewScrollToItem(at: IndexPath(item: containerRow, section: 0))
            }

            if scrollView == datesView {
                containersView.scrollToItem(at: IndexPath(item: datesRow, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == containersView {
            targetContentOffset.pointee = scrollView.contentOffset
            guard let indexPath = containersViewCenterIndexPath else { return }
            containersView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }

        if scrollView == datesView {
            targetContentOffset.pointee = scrollView.contentOffset
            guard let indexPath = datesViewCenterIndexPath else { return }
            datesViewScrollToItem(at: indexPath)
        }
    }
}
