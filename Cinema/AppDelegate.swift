//
//  AppDelegate.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let navController = window?.rootViewController as? UINavigationController

        navController?.navigationBar.isHidden = true

        // Opens `SettingsView` if the app is started for the first time or if UI tests commence.
        #warning("Review this!")
        if UserDefaults.standard.isFirstLaunch() || CommandLine.arguments.contains("ui-testing") {

        }

        return true
    }
}
