//
//  SettingsViewController.swift
//  Cinema
//
//  Created by Marius on 13/10/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import UIKit

private let reuseIdentifier = "settingsCell"

final class SettingsViewController: UITableViewController {
    private let datasource: [City] = {
        City.allCases.map { $0 }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView?.frame.size.height *= 2

        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Vertically center `tableView` content.
        let tableCenter = tableView.bounds.height / 2
        let contentCenter = tableView.contentSize.height / 2
        tableView.contentInset.top = tableCenter - contentCenter
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsViewCell

        cell.city.text = datasource[indexPath.row].rawValue

        let selectedCity = UserDefaults.standard.readCity()
        cell.isSelected = selectedCity == datasource[indexPath.row] ? true : false

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.save(city: datasource[indexPath.row])
        NotificationCenter.default.post(name: .SettingsDidChange, object: nil)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}
