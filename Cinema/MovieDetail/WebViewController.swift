//
//  WebViewController.swift
//  Cinema
//
//  Created by Marius on 2021-02-04.
//  Copyright © 2021 Marius. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController, WKUIDelegate {

    private let request: URLRequest

    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        return webView
    }()

    private lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Done",
            primaryAction: UIAction { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        )

        return button
    }()

    init(url: URL) {
        self.request = URLRequest(url: url)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Apollo website use transparent background, therefore view
        // background color needs to be adjusted for better visibility.
        if request.url?.absoluteString.contains(Venue.apollo.rawValue) ?? false {
            view.backgroundColor = .tertiaryBackground
        } else {
            view.backgroundColor = .primaryBackground
        }

        webView.isOpaque = false

        webView.load(request)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = rightButton
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
