//
//  MovieClient.swift
//  Cinema
//
//  Created by Marius on 2022-12-21.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import XCTestDynamicOverlay
import OrderedCollections

struct MovieClient {
    var fetch: (City, OrderedSet<Venue>) -> Effect<[Movie], MovieClient.Error>

    enum Error: Swift.Error, Equatable {
        case decoding
        case network
        case requiresUpdate
    }
}

extension DependencyValues {
    var movieClient: MovieClient {
        get { self[MovieClient.self] }
        set { self[MovieClient.self] = newValue }
    }
}

extension MovieClient: DependencyKey {
    static let liveValue = Self(
        fetch: { city, venues in
            guard !CommandLine.isUITesting else { return Effect(value: uiTestMovies) }
            let request = constructURLRequest(city: city, venues: venues)

            return URLSession.shared.dataTaskPublisher(for: request)
                .delay(for: .seconds(0.75), scheduler: RunLoop.main)
                .mapError { _ in
                    return MovieClient.Error.network
                }
                .tryMap { data, response in
                    guard let response = response as? HTTPURLResponse
                    else { throw MovieClient.Error.network }

                    if response.statusCode == 469 {
                        throw MovieClient.Error.requiresUpdate
                    }

                    do {
                        return try decoder.decode([Movie].self, from: data)
                    } catch {
                        print(error.localizedDescription)
                        throw MovieClient.Error.decoding
                    }
                }
                .mapError { error in
                    if let error = error as? MovieClient.Error {
                        return error
                    } else {
                        assert(true, "Unrecognized error received: \(error). Defaulting to Failure.network.")
                        return MovieClient.Error.network
                    }
                }
                .eraseToEffect()
        }
    )

    static let previewValue = Self(
        fetch: { _, _ in
            Effect(value: Array(repeating: Movie(showings: [Showing()]), count: 5))
        }
    )

    static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch")
    )

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

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

private extension MovieClient {
    static let uiTestMovies = {
        let today = Date()
        let tommorow = today.addingTimeInterval(86400)

        return [Movie(showings: [
            Showing(date: today),
            Showing(date: today),
            Showing(date: tommorow)
        ])]
    }()
}
