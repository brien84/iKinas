//
//  Showing.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import Foundation

struct Showing: Equatable, Identifiable {
    let ageRating: String
    let city: City
    let date: Date
    let duration: String
    let genres: [String]
    let id: UUID
    let is3D: Bool
    let originalTitle: String
    let plot: String
    let posterURL: URL
    let title: String
    let url: URL
    let venue: Venue
    let year: String

    init(
        ageRating: String = "N-18",
        city: City = .vilnius,
        date: Date = Date(timeIntervalSinceNow: .hour),
        duration: String = "90 min",
        genres: [String] = ["Drama", "Komedija"],
        id: UUID = UUID(),
        is3D: Bool = true,
        originalTitle: String = "Movie Title",
        plot: String = .loremIpsum,
        posterURL: URL = URL(string: "https://movies.ioys.lt/posters/example.png")!,
        title: String = "Filmo Pavadinimas",
        url: URL = URL(string: "https://www.ioys.lt/iKinas/")!,
        venue: Venue = .forum,
        year: String = "2020"
    ) {
        self.ageRating = ageRating
        self.city = city
        self.date = date
        self.duration = duration
        self.genres = genres
        self.id = id
        self.is3D = is3D
        self.originalTitle = originalTitle
        self.plot = plot
        self.posterURL = posterURL
        self.title = title
        self.url = url
        self.venue = venue
        self.year = year
    }
}

extension Showing {
    func isShown(on date: Date) -> Bool {
        if self.date < Date() { return false }
        let calendar = Calendar.current
        return calendar.isDate(self.date, inSameDayAs: date)
    }
}

extension Showing: Comparable {
    /// `Showing` are compared based on their `date` property value. In the event of a tie,
    /// the `title` and `venue` properties are used as tie-breakers.
    static func < (lhs: Showing, rhs: Showing) -> Bool {
        if lhs.date != rhs.date {
            return lhs.date < rhs.date
        } else {
            if lhs.title != rhs.title {
                return lhs.title < rhs.title
            } else {
                return lhs.venue.rawValue < rhs.venue.rawValue
            }
        }
    }
}

extension Array where Element == Showing {
    /// Returns `Dates` in the future corresponding to the days when `Showings` are scheduled.
    func getDays() -> [Date] {
        let dates = self.compactMap { showing -> Date? in
            guard showing.date > Date() else { return nil }
            return Calendar.current.startOfDay(for: showing.date)
        }
        return [Date](Set(dates)).sorted()
    }

    func filter(by date: Date) -> [Showing] {
        self.filter { showing in
            Calendar.current.isDate(showing.date, inSameDayAs: date)
        }.sorted()
    }
}
