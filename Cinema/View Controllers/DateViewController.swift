//
//  DateViewController.swift
//  Cinema
//
//  Created by Marius on 2020-07-29.
//  Copyright © 2020 Marius. All rights reserved.
//

import ComposableArchitecture
import UIKit

private let reuseIdentifier = "dateViewCell"

protocol DateViewControllerDelegate: AnyObject {
    func dateVC(_ dateVC: DateViewController, didUpdate datasource: [Movie])
}

final class DateViewController: UITableViewController {
    private let dates: DateTracking
    private let fetcher: MovieFetching

    weak var delegate: DateViewControllerDelegate?

    private lazy var loadingView: LoadingView = {
        let view = LoadingView(frame: tableView.frame)
        tableView.addSubview(view)
        view.delegate = self
        return view
    }()

    private var datasource = [Showing]() {
        didSet {
            datasource.sort()

            delegate?.dateVC(self, didUpdate: fetcher.getMovies(at: dates.selected))
            tableView.reloadData()
        }
    }

    required init?(coder: NSCoder) {
        self.dates = DateTracker()
        self.fetcher = MovieFetcher()

        super.init(coder: coder)
    }

    init?(coder: NSCoder, dates: DateTracking, fetcher: MovieFetching) {
        self.dates = dates
        self.fetcher = fetcher

        super.init(coder: coder)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        // Adjust `loadingView` height, since `loadingView` is initialized before `safeArea` is.
        loadingView.frame.size.height = tableView.frame.height - tableView.safeAreaInsets.top
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotificationObservers()

        fetchMovies()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIView.animate(withDuration: .stdAnimation / 2) { [self] in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datasource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DateViewCell

        let showing = datasource[indexPath.row]

        cell.poster.url = showing.parentMovie?.poster
        cell.title.text = showing.parentMovie?.title
        cell.originalTitle.text = showing.parentMovie?.originalTitle
        cell.venueImage.venue = showing.venue
        cell.time.text = showing.date.asString(.timeOfDay)
        cell.is3D = showing.is3D

        return cell
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(forName: .DateDidChange, object: nil, queue: .main) { [self] _ in
            updateDatasource()
            navigationItem.leftBarButtonItem?.image = dates.isFirst ? .settings : .arrowLeft
        }

        NotificationCenter.default.addObserver(forName: .SettingsDidChange, object: nil, queue: .main) { [self] _ in
            fetchMovies()
        }
    }

    private func fetchMovies() {
        prepareForFetching()
        loadingView.startLoading()

        fetcher.fetch(using: .shared) { result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success:
                    updateDatasource()
                case .failure(let error):
                    switch error {
                    case .requiresUpdate:
                        loadingView.show(.requiresUpdate, animated: false)
                    default:
                        print(error)
                        loadingView.show(.noNetwork, animated: false)
                    }
                }
            }
        }
    }

    private func updateDatasource() {
        if loadingView.isHidden {
            hiddenLoadingViewTransition()
        } else {
            visibleLoadingViewTransition()
        }
    }

    // MARK: - Navigation

    private func toggleEnabled(scroll: Bool, buttons: Bool) {
        tableView.isScrollEnabled = scroll
        navigationItem.leftBarButtonItem?.isEnabled = buttons
        navigationItem.rightBarButtonItem?.isEnabled = dates.isLast ? false : buttons
    }

    @IBAction private func leftNavigationBarButtonDidTap(_ sender: UIBarButtonItem) {
        dates.previous()
    }

    @IBAction private func rightNavigationBarButtonDidTap(_ sender: UIBarButtonItem) {
        dates.next()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedDateContainerVC" {
            guard let vc = segue.destination as? DateContainerViewController else { return }
            delegate = vc
            transitionTableView?.transitionDelegate = vc
        }

        if segue.identifier == "showMovieVC" {
            guard let vc = segue.destination as? MovieViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }

            let showing = datasource[indexPath.row]
            vc.movie = showing.parentMovie
            vc.showing = showing
        }
    }
}

extension DateViewController: LoadingViewDelegate {
    func loadingView(_ view: LoadingView, retryButtonDidTap: UIButton) {
        fetchMovies()
    }
}

// MARK: - Table Transitions

extension DateViewController {
    private var transitionTableView: TransitionTableView? {
        tableView as? TransitionTableView
    }

    private func prepareForFetching() {
        toggleEnabled(scroll: false, buttons: false)
        transitionTableView?.scrollToTop()
        transitionTableView?.transitionDelegate?.prepareForTransition(animated: false, completion: nil)
    }

    private func hiddenLoadingViewTransition() {
        toggleEnabled(scroll: false, buttons: false)

        transitionTableView?.prepareTransition { [self] in
            datasource = fetcher.getShowings(at: dates.selected)

            transitionTableView?.beginTransition { [self] in
                if datasource.count > 0 {
                    transitionTableView?.endTransition {
                        self.toggleEnabled(scroll: true, buttons: true)
                    }
                } else {
                    loadingView.show(.noMovies, animated: true) {
                        self.toggleEnabled(scroll: false, buttons: true)
                    }
                }
            }
        }
    }

    private func visibleLoadingViewTransition() {
        toggleEnabled(scroll: false, buttons: false)

        let overlay = UIView(frame: tableView.bounds)
        overlay.backgroundColor = tableView.backgroundColor
        tableView.addSubview(overlay)

        datasource = fetcher.getShowings(at: dates.selected)

        loadingView.hide { [self] in
            if datasource.count > 0 {
                overlay.removeFromSuperview()
                transitionTableView?.endTransition {
                    self.toggleEnabled(scroll: true, buttons: true)
                }
            } else {
                loadingView.show(.noMovies, animated: true) {
                    overlay.removeFromSuperview()
                    self.toggleEnabled(scroll: false, buttons: true)
                }
            }
        }
    }
}
