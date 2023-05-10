//
//  Extension+Calendar.swift
//  Cinema
//
//  Created by Marius on 2023-05-09.
//  Copyright © 2023 Marius. All rights reserved.
//

import Foundation

extension Calendar {
    /// Returns an array of `Date` objects for the next seven days, starting from and including today's date.
    func getNextSevenDays() -> [Date] {
        let now = Date()
        var dates = [Date]()

        for index in 0..<8 {
            guard let date = self.date(byAdding: .day, value: index, to: now)
            else { fatalError("Date generation failed!") }
            dates.append(date)
        }

        return dates
    }
}
