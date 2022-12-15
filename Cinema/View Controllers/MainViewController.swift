//
//  MainViewController.swift
//  Cinema
//
//  Created by Marius on 2022-12-15.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import UIKit

final class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction private func settingsButtonDidTap(_ sender: UIBarButtonItem) {
        let vc = SettingsViewHost(
            rootView: SettingsView(store: Store(initialState: Settings.State(), reducer: Settings()))
        )

        navigationController?.pushViewController(vc, animated: true)
    }
}
