//
//  Showing.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation
import OrderedCollections

struct Showing: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let ageRating: String
        let city: City
        let date: Date
        let duration: String
        let genres: OrderedSet<String>
        let metadata: OrderedSet<String>
        let id: UUID
        let is3D: Bool
        var networkImage: NetworkImage.State
        let originalTitle: String
        let plot: String
        let title: String
        let trailer: String?
        let url: URL
        let venue: Venue
        let year: String
    }

    enum Action: Equatable {
        case didSelect
        case networkImage(NetworkImage.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.networkImage, action: /Action.networkImage) {
            NetworkImage()
        }

        Reduce { _, action in
            switch action {
            case .didSelect:
                return .none
            case .networkImage:
                return .none
            }
        }
    }
}

private extension Showing.State {
    var genresWithMetadata: OrderedSet<String> {
        self.genres.union(self.metadata)
    }
}

extension Array where Element == Showing.State {
    func convertToIdentifiedArray() -> IdentifiedArrayOf<Showing.State> {
        IdentifiedArray(uniqueElements: self)
    }
}

extension IdentifiedArrayOf where Element == Showing.State, ID == UUID {
    func filter(by date: Date) -> IdentifiedArrayOf<Element> {
        self.filter { showing in
            Calendar.current.isDate(showing.date, inSameDayAs: date)
        }
    }

    func filter(by title: String) -> IdentifiedArrayOf<Element> {
        self.filter { showing in
            title == showing.title
        }
    }

    func filter(from startDate: Date, to endDate: Date) -> IdentifiedArrayOf<Element> {
        self.filter {
            $0.date >= startDate && $0.date <= endDate
        }
    }

    /// Returns `IdentifiedArrayOf<Showing.State>` containing elements which share certain amount of `genres` and `metadata` entries.
    func filter(similarTo showing: Showing.State) -> IdentifiedArrayOf<Element> {
        var titles = self.getUniqueTitles()
        titles.remove(showing.title)
        let showings = self.filterFirstOccurrencesOf(titles: titles)
        let threshold = showing.genresWithMetadata.count > 1 ? 2 : 1

        return showings.filter {
            $0.genresWithMetadata.intersection(showing.genresWithMetadata).count >= threshold
        }
    }

    /// Returns `IdentifiedArrayOf<Showing.State>` containing only the first occurrence of element with each provided `title` property.
    func filterFirstOccurrencesOf(titles: Set<String>) -> IdentifiedArrayOf<Element> {
        titles.compactMap { title in
            self.first { showing in
                showing.title == title
            }
        }.convertToIdentifiedArray()
    }

    /// Returns `IdentifiedArrayOf<Showing.State>` elements whose `date` property is later than the current date.
    func filterFutureShowings() -> IdentifiedArrayOf<Element> {
        self.filter {
            $0.date > Date()
        }.convertToIdentifiedArray()
    }

    /// Returns a set of unique `title` properties from the `IdentifiedArrayOf<Showing.State>`.
    func getUniqueTitles() -> Set<String> {
        Set(self.map { $0.title })
    }

    /// Returns an array of `Date` objects, each representing the start of a day for the upcoming showings, with duplicates removed.
    func getUpcomingDays() -> [Date] {
        let dates = self.map { showing in
            Calendar.current.startOfDay(for: showing.date)
        }
        return [Date](Set(dates)).sorted()
    }

    mutating func sort(by option: Showing.SortOption) {
        switch option {
        case .date:
            sortByDate()
        case .title:
            sortByTitle()
        }
    }

    /// Sorts `IdentifiedArrayOf<Showing.State>` based on elements `date` properties.
    /// If multiple elements share the same `date`, further sorting is done based on `title` and then `venue` properties.
    private mutating func sortByDate() {
        self.sort(by: {
            if $0.date != $1.date {
                return $0.date < $1.date
            } else {
                if $0.title != $1.title {
                    return $0.title.compare($1.title, locale: Locale.app) == .orderedAscending
                } else {
                    return $0.venue.rawValue < $1.venue.rawValue
                }
            }
        })
    }

    private mutating func sortByTitle() {
        self.sort(by: {
            $0.title.compare($1.title, locale: Locale.app) == .orderedAscending
        })
    }
}

extension Showing {
    enum SortOption {
        case title
        case date
    }
}
