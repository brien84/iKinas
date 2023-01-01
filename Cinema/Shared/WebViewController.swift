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
    var url: URL?

    @IBOutlet private weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.uiDelegate = self

        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    @IBAction private func doneButtonDidTap(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
