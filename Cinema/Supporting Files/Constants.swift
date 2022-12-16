//
//  Constants.swift
//  Cinema
//
//  Created by Marius on 25/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
    static let primaryElement = Color("primaryElement")
    static let secondaryElement = Color("secondaryElement")
    static let tertiaryElement = Color("tertiaryElement")
    static let primaryBackground = Color("primaryBackground")
    static let secondaryBackground = Color("secondaryBackground")
}

extension Notification.Name {
    static let dateDidChange = Notification.Name("DateDidChangeNotification")
    static let settingsDidChange = Notification.Name("SettingsDidChangeNotification")
}

extension NotificationCenter {
    static let dateViewControlsIsEnabledKey = "dateViewControlsIsEnabled"
    static let selectedDateKey = "selectedDate"
}

extension TimeInterval {
    static let stdAnimation = 0.4
}

extension UIColor {
    static let primaryElement = UIColor(named: "primaryElement")!
    static let secondaryElement = UIColor(named: "secondaryElement")!
    static let tertiaryElement = UIColor(named: "tertiaryElement")!
    static let primaryBackground = UIColor(named: "primaryBackground")!
    static let secondaryBackground = UIColor(named: "secondaryBackground")!
}

extension UIImage {
    static let arrowLeft = UIImage(named: "arrowLeft")!
    static let arrowRight = UIImage(named: "arrowRight")!
    static let settings = UIImage(named: "settings")!
    static let navTicket = UIImage(named: "navTicket")

    static let apollo = UIImage(named: "apollo")!
    static let atlantis = UIImage(named: "atlantis")!
    static let cinamon = UIImage(named: "cinamon")!
    static let forum = UIImage(named: "forum")!
    static let multikino = UIImage(named: "multikino")!
}

extension URL {
    static let appStore = URL(string: "https://apps.apple.com/app/id1501977644")!

    static let api = URL(string: "https://movies.ioys.lt/")!
    // static let api = URL(string: "http://localhost:8080/")!
}

extension UserDefaults {
    static let cityKey = "UserDefaultsCityKey"
    static let venuesKey = "UserDefaultsVenuesKey"
}
