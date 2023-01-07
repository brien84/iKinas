//
//  Extensions.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import SwiftUI
import UIKit

extension Date {
    enum StringFormat {
        case dateAndTime
        case monthAndDay
        case timeOfDay
    }

    /// Converts `Date` to `String`.
    func asString(_ format: StringFormat = .dateAndTime) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "lt")

        switch format {
        case .dateAndTime:
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        case .monthAndDay:
            if Calendar.current.isDateInToday(self) { return "Šiandien" }
            if Calendar.current.isDateInTomorrow(self) { return "Rytoj" }
            formatter.dateFormat = "MMMM d"
        case .timeOfDay:
            formatter.dateFormat = "HH:mm"
        }

        return formatter.string(from: self)
    }
}

extension UIColor {
    /// Creates `UIImage` filled with `UIColor`.
    func image(size: CGSize, isEclipse: Bool = false) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { rendererContext in
            let rect = CGRect(origin: .zero, size: size)
            self.setFill()

            if isEclipse {
                rendererContext.cgContext.fillEllipse(in: rect)
            } else {
                rendererContext.fill(rect)
            }
        }
    }
}

extension UINavigationBar {
    func setBackgroundImage(color: UIColor, alpha: CGFloat = 1.0) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        // If `alpha` is equal or higher than 1.0 `UINavigationBar`
        // will apply a system-defined alpha value.
        let alpha = alpha >= 0.99 ? 0.99 : alpha
        let color = color.withAlphaComponent(alpha)

        // `UINavigationBar` will size the image to fill.
        appearance.backgroundImage = color.image(size: CGSize(width: 1, height: 1))

        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
    }
}

extension UserDefaults {
    func isFirstLaunch() -> Bool {
        guard
            self.string(forKey: Self.cityKey) != nil,
            self.array(forKey: Self.venuesKey) != nil
        else {
            return true
        }

        return false
    }

    func readCity() -> City {
        guard
            let rawValue = self.string(forKey: Self.cityKey),
            let city = City(rawValue: rawValue)
        else {
            return .vilnius
        }

        return city
    }

    func readVenues() -> [Venue] {
        guard let rawValues = self.array(forKey: Self.venuesKey) as? [String]
        else { return Array(self.readCity().venues) }

        let venues = rawValues.compactMap { Venue(rawValue: $0) }
        guard !venues.isEmpty else { return Array(self.readCity().venues) }

        return venues
    }

    func save(city: City, venues: [Venue]) {
        self.set(city.rawValue, forKey: Self.cityKey)
        self.set(venues.map { $0.rawValue }, forKey: Self.venuesKey)
    }
}

extension View {
    /// Dinamically hides and disables view.
    ///
    /// Since iOS15 the behaviour of `XCUIElement` `isHittable` property
    /// has changed in a way that it no longer returns true if `View` opacity is zero.
    /// As a workaround this function hides and also disables the `View`
    /// therefore we can now assert on `XCUIElement` `isEnabled` property.
    func hidden(_ hidden: Bool) -> some View {
        opacity(hidden ? 0 : 1).disabled(hidden)
    }
}
