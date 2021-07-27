//
//  Models+Testable.swift
//  CinemaTests
//
//  Created by Marius on 2020-11-12.
//  Copyright © 2020 Marius. All rights reserved.
//

// swiftlint:disable force_try
import XCTest
@testable import iKinas

// MARK: - Movie

private struct MovieDouble: Codable {
    let title: String
    let originalTitle: String
    let year: String
    let ageRating: String
    let duration: String
    let genres: [String]
    let plot: String
    let poster: URL
    var showings: [Showing]
}

extension Movie {
    static func create(_ title: String, _ originalTitle: String, _ year: String, _ ageRating: String,
                       _ duration: String, _ genres: [String], _ plot: String, _ poster: URL, _ showings: [Showing]) -> Movie {
        let double = MovieDouble(title: title, originalTitle: originalTitle, year: year, ageRating: ageRating,
                                 duration: duration, genres: genres, plot: plot, poster: poster, showings: showings)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(double)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(Movie.self, from: data)
    }
}

extension Array where Element == Movie {
    func encoded() -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(self) else {
            fatalError("Could not encode movies!")
        }

        return data
    }
}

// MARK: - Showing

private struct ShowingDouble: Codable {
    let city: City
    let date: Date
    let venue: Venue
    let is3D: Bool
    let url: URL
}

extension Showing {
    static func create(_ city: City, _ date: Date, _ venue: Venue, _ is3D: Bool, _ url: URL) -> Showing {
        let double = ShowingDouble(city: city, date: date, venue: venue, is3D: is3D, url: url)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(double)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(Showing.self, from: data)
    }
}

// MARK: - Date

extension Date {
    /// Returns current date one hour in the future.
    static var today: Date {
        let current = Date().timeIntervalSinceReferenceDate.rounded(.down)

        return Date(timeIntervalSinceReferenceDate: current + 3600)
    }

    /// Returns current date 25 hours in the future.
    static var tommorow: Date {
        let current = Date().timeIntervalSinceReferenceDate.rounded(.down)

        return Date(timeIntervalSinceReferenceDate: current + 90000)
    }
}
