//
//  LiveAPIClient.swift
//  Cinema
//
//  Created by Marius on 2023-06-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import Combine
import ComposableArchitecture
import Foundation
import OrderedCollections

extension APIClient: DependencyKey {
    static var liveValue: Self {
        var showings = [Showing]()

        return Self(
            fetch: { city, venues in
                let request = constructURLRequest(city: city, venues: venues)

                return URLSession.shared.dataTaskPublisher(for: request)
                    .map { data, response in
                        let response = response as? HTTPURLResponse
                        if response?.statusCode == 469 {
                            return .failure(.requiresUpdate)
                        }

                        do {
                            showings = try ShowingsService.decode(data: data)
                            return .success
                        } catch {
                            print(error.localizedDescription)
                            return .failure(.decoding)
                        }
                    }
                    .catch { _ in
                        Just(.failure(.network))
                    }
                    .eraseToEffect()
            },
            getShowings: {
                showings
            }
        )
    }

    private static func constructURLRequest(city: City, venues: OrderedSet<Venue>) -> URLRequest {
        let cityPath = city.rawValue
        let venuesPath = venues.map { String($0.rawValue) }.joined(separator: ",")
        let path = "\(cityPath)/\(venuesPath)"

        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else { fatalError("App Version not found!") }

        var request = URLRequest(url: URL.api.appendingPathComponent(path))
        request.setValue(version, forHTTPHeaderField: "iOS-Client-Version")

        return request
    }
}

private struct ShowingsService {
    static func decode(data: Data) throws -> [iKinas.Showing] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([ShowingsService.Movie].self, from: data).flatMap { movie in
            movie.showings.map { showing in
                iKinas.Showing(
                    ageRating: movie.ageRating,
                    city: showing.city,
                    date: showing.date,
                    duration: movie.duration,
                    genres: movie.genres,
                    id: showing.id,
                    is3D: showing.is3D,
                    originalTitle: movie.originalTitle,
                    plot: movie.plot,
                    posterURL: movie.poster,
                    title: movie.title,
                    url: showing.url,
                    venue: showing.venue,
                    year: movie.year
                )
            }
        }
    }

    private struct Movie: Decodable {
        let ageRating: String
        let duration: String
        let genres: [String]
        let originalTitle: String
        let plot: String
        let poster: URL
        let showings: [ShowingsService.Showing]
        let title: String
        let year: String
    }

    private struct Showing: Decodable {
        let city: City
        let date: Date
        let id: UUID
        let is3D: Bool
        let url: URL
        let venue: Venue
    }
}
