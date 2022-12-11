//
//  MovieFetcher.swift
//  Cinema
//
//  Created by Marius on 2020-11-15.
//  Copyright © 2020 Marius. All rights reserved.
//

import UIKit

protocol MovieFetching {
    var userDefaults: UserDefaults { get }
    func getMovies(at date: Date) -> [Movie]
    func getShowings(at date: Date) -> [Showing]
    func fetch(using session: URLSession, completion: @escaping (Result<Void, FetchingError>) -> Void)
}

enum FetchingError: Error {
    case decodingFailed(Error)
    case networkFailed(Error)
    case requiresUpdate
}

final class MovieFetcher: MovieFetching {
    private var movies = [Movie]()
    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getMovies(at date: Date) -> [Movie] {
        let movies = getShowings(at: date).compactMap { showing in
            showing.parentMovie
        }

        return Array(Set(movies))
    }

    func getShowings(at date: Date) -> [Showing] {
        movies.flatMap { movie in
            movie.showings.filter { $0.isShown(on: date) }
        }
    }

    func fetch(using session: URLSession = .shared, completion: @escaping (Result<Void, FetchingError>) -> Void) {
        if CommandLine.arguments.contains("ui-testing") {
            guard let data = NSDataAsset(name: "UITestData")?.data
            else { fatalError("Cannot load UITestData!") }

            completion(decode(data))
        } else {
            let task = session.dataTask(with: constructURL()) { data, response, error in
                if let error {
                    completion(.failure(.networkFailed(error)))
                    return
                }

                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 469 {
                        completion(.failure(.requiresUpdate))
                        return
                    }
                }

                if let data {
                    completion(self.decode(data))
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                task.resume()
            }
        }
    }

    private func decode(_ data: Data) -> Result<Void, FetchingError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            self.movies = try decoder.decode([Movie].self, from: data)
            return .success(())
        } catch {
            return .failure(.decodingFailed(error))
        }
    }

    private func constructURL() -> URL {
        guard let versionPath = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else { fatalError("App Version not found!") }

        let city = userDefaults.readCity()
        let cityPath = city.rawValue

        let venues = userDefaults.readVenues()
        let venuesPath = venues.map { String($0.rawValue) }.joined(separator: ",")

        let path = "\(versionPath)/\(cityPath)/\(venuesPath)"

        return URL.api.appendingPathComponent(path)
    }
}
