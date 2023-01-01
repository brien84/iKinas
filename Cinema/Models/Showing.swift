//
//  Showing.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import Foundation

final class Showing: Codable {
    let city: City
    let date: Date
    let venue: Venue
    let is3D: Bool
    let url: URL
    weak var parentMovie: Movie?

    init(
        city: City = .vilnius,
        date: Date = Date(timeIntervalSinceNow: 60),
        venue: Venue = .forum,
        is3D: Bool = false,
        url: URL = URL(string: "https://movies.ioys.lt/")!
    ) {
        self.city = city
        self.date = date
        self.venue = venue
        self.is3D = is3D
        self.url = url
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.city = try values.decode(City.self, forKey: .city)
        self.date = try values.decode(Date.self, forKey: .date)
        self.venue = try values.decode(Venue.self, forKey: .venue)
        self.is3D = try values.decode(Bool.self, forKey: .is3D)
        self.url = try values.decode(URL.self, forKey: .url)
    }

    private enum CodingKeys: String, CodingKey {
        case city
        case date
        case venue
        case is3D
        case url
    }
}

extension Showing {
    func isShown(on date: Date) -> Bool {
        // Check if `self.date` is not in the past.
        if self.date < Date() { return false }

        let calendar = Calendar.current
        return calendar.isDate(self.date, inSameDayAs: date)
    }
}

extension Showing: Comparable {
    /// `Showing` are compared based on their `date` property value. In the event of a tie,
    /// the `parentMovie.title` and `venue` properties are used as tie-breakers.
    static func < (lhs: Showing, rhs: Showing) -> Bool {
        if lhs.date != rhs.date {
            return lhs.date < rhs.date
        } else {
            guard let lhsTitle = lhs.parentMovie?.title else { return false }
            guard let rhsTitle = rhs.parentMovie?.title else { return true }

            if lhsTitle != rhsTitle {
                return lhsTitle < rhsTitle
            } else {
                return lhs.venue.rawValue < rhs.venue.rawValue
            }
        }
    }

    static func == (lhs: Showing, rhs: Showing) -> Bool {
        lhs.date == rhs.date && lhs.parentMovie?.title == rhs.parentMovie?.title && lhs.venue == rhs.venue
    }
}
