//
//  AppDelegate.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let navController = window?.rootViewController as? UINavigationController
        navController?.navigationBar.isHidden = true

        window?.overrideUserInterfaceStyle = .dark

        return true
    }
}

extension CommandLine {
    static var isUITesting: Bool {
        Self.arguments.contains("ui-testing")
    }

    static var isUITestingFirstLaunch: Bool {
        Self.arguments.contains("ui-testing-first-launch")
    }
}
