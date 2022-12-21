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
    private let fetcher: MovieFetching
    private var selectedDate = Date()

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

            delegate?.dateVC(self, didUpdate: fetcher.getMovies(at: selectedDate))
            tableView.reloadData()
        }
    }

    required init?(coder: NSCoder) {
        self.fetcher = MovieFetcher()

        super.init(coder: coder)
    }

    init?(coder: NSCoder, fetcher: MovieFetching) {
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
        NotificationCenter.default.addObserver(forName: .dateDidChange, object: nil, queue: .main) { [self] notification in
            guard let info = notification.userInfo as? [String: Date] else { return }
            guard let date = info[NotificationCenter.selectedDateKey] else { return }
            selectedDate = date

            updateDatasource()
        }

        NotificationCenter.default.addObserver(forName: .settingsDidChange, object: nil, queue: .main) { [self] _ in
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

    private func toggleControls(enabled isEnabled: Bool) {
        tableView.isScrollEnabled = isEnabled

        let info: [String: Bool] = [NotificationCenter.dateViewControlsIsEnabledKey: isEnabled]
        NotificationCenter.default.post(name: .dateViewControlsStateDidChange, object: nil, userInfo: info)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        toggleControls(enabled: false)
        transitionTableView?.scrollToTop()
        transitionTableView?.transitionDelegate?.prepareForTransition(animated: false, completion: nil)
    }

    private func hiddenLoadingViewTransition() {
        toggleControls(enabled: false)

        transitionTableView?.prepareTransition { [self] in
            datasource = fetcher.getShowings(at: selectedDate)

            transitionTableView?.beginTransition { [self] in
                if datasource.count > 0 {
                    transitionTableView?.endTransition {
                        self.toggleControls(enabled: true)
                    }
                } else {
                    loadingView.show(.noMovies, animated: true) {
                        self.toggleControls(enabled: false)
                    }
                }
            }
        }
    }

    private func visibleLoadingViewTransition() {
        toggleControls(enabled: false)

        let overlay = UIView(frame: tableView.bounds)
        overlay.backgroundColor = tableView.backgroundColor
        tableView.addSubview(overlay)

        datasource = fetcher.getShowings(at: selectedDate)

        loadingView.hide { [self] in
            if datasource.count > 0 {
                overlay.removeFromSuperview()
                transitionTableView?.endTransition {
                    self.toggleControls(enabled: true)
                }
            } else {
                loadingView.show(.noMovies, animated: true) {
                    overlay.removeFromSuperview()
                    self.toggleControls(enabled: false)
                }
            }
        }
    }
}
