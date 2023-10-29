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
        var featured = IdentifiedArrayOf<Featured.State>()
        var showings = IdentifiedArrayOf<Showing.State>()

        return Self(
            fetch: { city, venues in
                let featuredReq = constructRequest(city: city, venues: venues, url: .featuredAPI)
                let showingsReq = constructRequest(city: city, venues: venues, url: .api)

                let featuredTask = URLSession.shared.dataTaskPublisher(for: featuredReq)
                let showingsTask = URLSession.shared.dataTaskPublisher(for: showingsReq)

                return featuredTask.combineLatest(showingsTask).map { (featuredResult, showingsResult) in
                    if checkIfUpdateIsRequired(in: featuredResult.response, showingsResult.response) {
                        return .failure(.requiresUpdate)
                    }

                    do {
                        featured = try FeaturedService.decode(data: featuredResult.data)
                        showings = try ShowingsService.decode(data: showingsResult.data)
                        return .success
                    } catch {
                        print(error.localizedDescription)
                        return .failure(.decoding)
                    }
                }
                .catch { _ in
                    Just(Response.failure(.network))
                }
                .eraseToEffect()
            },
            getFeatured: {
                featured
            },
            getShowings: {
                showings.filterFutureShowings()
            }
        )
    }

    private static func checkIfUpdateIsRequired(in responses: URLResponse...) -> Bool {
        for response in responses {
            let response = response as? HTTPURLResponse
            if response?.statusCode == 469 { return true }
        }
        return false
    }

    private static func constructRequest(city: City, venues: OrderedSet<Venue>, url: URL) -> URLRequest {
        let cityPath = city.rawValue
        let venuesPath = venues.map { String($0.rawValue) }.joined(separator: ",")
        let path = "\(cityPath)/\(venuesPath)"

        var request = URLRequest(url: url.appendingPathComponent(path))
        request.setValue(Bundle.main.version, forHTTPHeaderField: "iOS-Client-Version")

        return request
    }
}

private struct ShowingsService {
    static func decode(data: Data) throws -> IdentifiedArrayOf<iKinas.Showing.State> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([ShowingsService.Movie].self, from: data).flatMap { movie in
            movie.showings.map { showing in
                iKinas.Showing.State(
                    ageRating: movie.ageRating,
                    city: showing.city,
                    date: showing.date,
                    duration: movie.duration,
                    genres: movie.genres,
                    id: showing.id,
                    is3D: showing.is3D,
                    networkImage: NetworkImage.State(url: movie.poster),
                    originalTitle: movie.originalTitle,
                    plot: movie.plot,
                    title: movie.title,
                    url: showing.url,
                    venue: showing.venue,
                    year: movie.year
                )
            }
        }.convertToIdentifiedArray()
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

private struct FeaturedService {
    static func decode(data: Data) throws -> IdentifiedArrayOf<iKinas.Featured.State> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let featured = try decoder.decode([FeaturedService.Featured].self, from: data).map { featured in
            iKinas.Featured.State(
                id: featured.id,
                label: featured.label,
                networkImage: NetworkImage.State(url: featured.imageURL),
                originalTitle: featured.originalTitle,
                title: featured.title
            )
        }

        return IdentifiedArray(uniqueElements: featured)
    }

    private struct Featured: Decodable {
        let id: UUID
        let imageURL: URL
        let label: String
        let originalTitle: String
        let title: String
    }
}
