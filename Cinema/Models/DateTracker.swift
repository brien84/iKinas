//
//  DateTracker.swift
//  Cinema
//
//  Created by Marius on 23/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import Foundation

protocol DateTracking {
    var selected: Date { get }
    var isFirst: Bool { get }
    var isLast: Bool { get }

    func previous()
    func next()
}

final class DateTracker: DateTracking {
    static var dates = [Date]()

    private var _dates: [Date] {
        return DateTracker.dates
    }

    private var selectedIndex = 0 {
        didSet {
            postNotification()
        }
    }

    var selected: Date {
        return _dates[selectedIndex]
    }

    var isFirst: Bool {
        return selectedIndex == 0
    }

    var isLast: Bool {
        return selectedIndex == _dates.indices.last
    }

    init() {
        if CommandLine.arguments.contains("ui-testing") {
            // Testing start date is 2030-01-01.
            DateTracker.dates = Date(timeIntervalSince1970: 1893456000).futureDatesIn(days: 10)
        } else {
            DateTracker.dates = Date().futureDatesIn(days: 10)
        }
    }

    private func postNotification() {
        NotificationCenter.default.post(name: .DateTrackerDateDidChange, object: nil)
    }

    func previous() {
        if !isFirst {
            selectedIndex -= 1
        }
    }

    func next() {
        if !isLast {
            selectedIndex += 1
        }
    }
}

extension Date {
    /// Creates array of `Date` by adding one day to the date provided number of times.
    ///
    /// - Example:
    ///     ```
    ///     let dates = futureDatesIn(after: 2)
    ///     print(dates)
    ///     // Prints "[2020-02-22 16:37:31 +0000,
    ///     //          2020-02-23 16:37:31 +0000,
    ///     //          2020-02-24 16:37:31 +0000]"
    ///     ```
    fileprivate func futureDatesIn(days: Int) -> [Date] {
        var date = self
        guard let endDate = Calendar.current.date(byAdding: .day, value: days, to: date) else { return [] }
        var dates = [Date]()

        while date <= endDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return [] }
            date = newDate
        }

        return dates
    }
}

extension Notification.Name {
    static let DateTrackerDateDidChange = Notification.Name("DateTrackerDateDidChangeNotification")
}
