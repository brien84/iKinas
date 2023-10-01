//
//  Extension+Date.swift
//  Cinema
//
//  Created by Marius on 2023-01-08.
//  Copyright © 2023 Marius. All rights reserved.
//

import Foundation

extension Date {
    static var none = Date.distantPast

    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.app
        return formatter
    }()

    func formatted(_ format: DateFormat) -> String {
        let isToday = Calendar.current.isDateInToday(self)

        switch format {
        case .dayOfWeek:
            if isToday { return "Šiandien" }
            Self.formatter.weekdaySymbols = Self.formatter.weekdaySymbols.map { $0.capitalized }
            Self.formatter.dateFormat = "EEEE"

        case .monthAndDay:
            Self.formatter.dateFormat = isToday ? "EEEE, MMMM d" : "MMMM d"

        case .shortDayOfWeek:
            if isToday { return "ŠND" }
            Self.formatter.shortWeekdaySymbols = ["SEK", "PIR", "ANT", "TRE", "KET", "PEN", "ŠEŠ"]
            Self.formatter.dateFormat = "EEE"

        case .shortMonthAndDay:
            Self.formatter.shortMonthSymbols = ["Sau", "Vas", "Kov", "Bal", "Geg", "Bir", "Lie", "Rgp", "Rgs", "Spa", "Lap", "Gru"]
            Self.formatter.dateFormat = "MMM d"

        case .timeOfDay:
            Self.formatter.dateFormat = "HH:mm"
        }

        return Self.formatter.string(from: self)
    }
}

extension Date {
    /// An enumeration of formats for converting a `Date` object to a `String` representation.
    enum DateFormat {
        /// Displays the full name of the day of the week.
        ///
        /// if date is in today:
        /// ```
        /// Šiandien
        /// ```
        /// else
        /// ```
        /// Pirmadienis
        /// ```
        case dayOfWeek

        /// Displays the month and day.
        ///
        /// if date is in today:
        /// ```
        /// Pirmadienis, Sausio 11
        /// ```
        /// else
        /// ```
        /// Sausio 11
        /// ```
        case monthAndDay

        /// Displays the abbreviated name of day of the week.
        ///
        /// if date is in today:
        /// ```
        /// ŠND
        /// ```
        /// else
        /// ```
        /// PIR
        /// ```
        case shortDayOfWeek

        /// Displays the abbreviated month name, followed by the day.
        ///
        /// ```
        /// Sau 11
        /// ```
        case shortMonthAndDay

        /// Displays the time of day, in hours, minutes.
        ///
        /// ```
        /// 11:20
        /// ```
        case timeOfDay
    }
}
