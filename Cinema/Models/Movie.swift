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

private extension String {
    static let loremIpsum =
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vulputate sapien interdum auctor pharetra.
        Aenean ut facilisis lectus. Ut metus eros, convallis eu orci vel, lacinia porttitor lacus.
        Integer lorem leo, maximus vel sapien vitae, pretium aliquam eros.
        Nunc fringilla egestas enim, a ullamcorper dolor imperdiet finibus.
        Mauris consectetur ut justo vel euismod. Curabitur non mollis nisl.

        Etiam lobortis cursus commodo. Duis congue ligula quis urna volutpat elementum. Nam in erat felis.
        Fusce ornare nulla sed elit placerat, sagittis dignissim ligula viverra. Maecenas non placerat leo.
        Proin eu sollicitudin lectus, bibendum cursus lacus. In et tempor nisi, quis finibus est.
        Nunc consequat non lorem nec rutrum. Suspendisse potenti. Cras posuere rhoncus laoreet.
        Etiam eu tellus vel erat egestas volutpat maximus ut mi.
        Pellentesque erat nisi, aliquam id lacus ut, mollis vestibulum sem.
        Vivamus volutpat posuere quam, vitae euismod eros posuere non. Sed pellentesque rutrum vestibulum.
        Sed maximus vitae felis eleifend malesuada.

        Sed consequat quis lorem eget consequat. Donec porta libero in magna euismod imperdiet tincidunt in neque.
        Etiam dictum nisl vitae fringilla posuere. Maecenas nec justo facilisis, efficitur nisl eget, fermentum nibh.
        Sed tempor eros ex, a semper est placerat sed.
        Aenean egestas, lacus quis luctus ultrices, odio erat consectetur sem, vitae imperdiet orci metus quis turpis.
        Integer ac lorem ac nunc interdum consectetur. Etiam eu dui sit amet ex dapibus eleifend.
        """
}
