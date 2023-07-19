//
//  Movie.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import Foundation

final class Movie: Codable {
    let id: UUID
    let title: String
    let originalTitle: String
    let year: String
    let ageRating: String
    let duration: String
    let genres: [String]
    let plot: String
    let poster: URL
    var showings: [Showing]

    init(
        id: UUID = UUID(),
        title: String = "Filmo Pavadinimas",
        originalTitle: String = "Movie Title",
        year: String = "2017",
        ageRating: String = "V",
        duration: String = "120 min",
        genres: [String] = ["Drama", "Komedija"],
        plot: String = .loremIpsum,
        poster: URL = URL(string: "https://movies.ioys.lt/posters/example.png")!,
        showings: [Showing] = []
    ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.year = year
        self.ageRating = ageRating
        self.duration = duration
        self.genres = genres
        self.plot = plot
        self.poster = poster
        self.showings = showings

        self.showings = showings.map { showing -> Showing in
            let showing = showing
            showing.parentMovie = self
            return showing
        }
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decode(UUID.self, forKey: .id)
        self.title = try values.decode(String.self, forKey: .title)
        self.originalTitle = try values.decode(String.self, forKey: .originalTitle)
        self.year = try values.decode(String.self, forKey: .year)
        self.ageRating = try values.decode(String.self, forKey: .ageRating)
        self.duration = try values.decode(String.self, forKey: .duration)
        self.genres = try values.decode([String].self, forKey: .genres)
        self.plot = try values.decode(String.self, forKey: .plot)
        self.poster = try values.decode(URL.self, forKey: .poster)
        self.showings = try values.decode([Showing].self, forKey: .showings)

        self.showings = showings.map { showing -> Showing in
            let showing = showing
            showing.parentMovie = self
            return showing
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle
        case year
        case ageRating
        case duration
        case genres
        case plot
        case poster
        case showings
    }
}

extension Movie: Comparable {
    static func < (lhs: Movie, rhs: Movie) -> Bool {
        let locale = Locale(identifier: "lt")
        return lhs.title.compare(rhs.title, locale: locale) == .orderedAscending
    }
}

extension Movie: Equatable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.title == rhs.title
    }
}

extension Movie: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
