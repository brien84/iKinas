//
//  MovieClient.swift
//  Cinema
//
//  Created by Marius on 2022-12-21.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct MovieClient {
    var fetch: () -> Effect<[Movie], MovieClient.Error>

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
        fetch: {
            URLSession.shared.dataTaskPublisher(for: constructURLRequest())
                .delay(for: .seconds(1.0), scheduler: RunLoop.main)
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
        fetch: {
            Effect(value: Array(repeating: Movie(showings: [Showing()]), count: 5))
        }
    )

    static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch")
    )

    private static func constructURLRequest() -> URLRequest {
        let city = UserDefaults.standard.readCity()
        let cityPath = city.rawValue
        let venues = UserDefaults.standard.readVenues()
        let venuesPath = venues.map { String($0.rawValue) }.joined(separator: ",")
        let path = "\(cityPath)/\(venuesPath)"

        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else { fatalError("App Version not found!") }

        var request = URLRequest(url: URL.api.appendingPathComponent(path))
        request.setValue(version, forHTTPHeaderField: "iOS-Client-Version")

        return request
    }
}

private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()
