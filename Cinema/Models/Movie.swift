//
//  Movie.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import Foundation

final class Movie: Codable {
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
        title: String = "Filmo Pavadinimas",
        originalTitle: String = "Movie Title",
        year: String = "2017",
        ageRating: String = "V",
        duration: String = "120 min",
        genres: [String] = ["Drama", "Komedija"],
        plot: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit!",
        poster: URL = URL(string: "https://movies.ioys.lt/posters/example.png")!,
        showings: [Showing] = []
    ) {
        self.title = title
        self.originalTitle = originalTitle
        self.year = year
        self.ageRating = ageRating
        self.duration = duration
        self.genres = genres
        self.plot = plot
        self.poster = poster
        self.showings = showings
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        title = try values.decode(String.self, forKey: .title)
        originalTitle = try values.decode(String.self, forKey: .originalTitle)
        year = try values.decode(String.self, forKey: .year)
        ageRating = try values.decode(String.self, forKey: .ageRating)
        duration = try values.decode(String.self, forKey: .duration)
        genres = try values.decode([String].self, forKey: .genres)
        plot = try values.decode(String.self, forKey: .plot)
        poster = try values.decode(URL.self, forKey: .poster)
        showings = try values.decode([Showing].self, forKey: .showings)

        showings = showings.map { showing -> Showing in
            let showing = showing
            showing.parentMovie = self
            return showing
        }
    }

    private enum CodingKeys: String, CodingKey {
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

extension Movie: Hashable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
