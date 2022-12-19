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
        date: Date = Date(),
        venue: Venue = .forum,
        is3D: Bool = false,
        url: URL = URL(string: "https://movies.ioys.lt/")!,
        parentMovie: Movie? = Movie()
    ) {
        self.city = city
        self.date = date
        self.venue = venue
        self.is3D = is3D
        self.url = url
        self.parentMovie = parentMovie
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        city = try values.decode(City.self, forKey: .city)
        date = try values.decode(Date.self, forKey: .date)
        venue = try values.decode(Venue.self, forKey: .venue)
        is3D = try values.decode(Bool.self, forKey: .is3D)
        url = try values.decode(URL.self, forKey: .url)
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
        // Is `self.date` in the past.
        if self.date < Date() { return false }

        let calendar = Calendar.current
        return calendar.isDate(self.date, inSameDayAs: date)
    }
}

extension Showing: Comparable {
    /// Compares by `date` with`parentMovie.title` and `venue` tie-breaks.
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
