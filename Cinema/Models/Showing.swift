//
//  Showing.swift
//  Cinema
//
//  Created by Marius on 21/09/2019.
//  Copyright © 2019 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct Showing: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let ageRating: String
        let city: City
        let date: Date
        let duration: String
        let genres: [String]
        let id: UUID
        let is3D: Bool
        var networkImage: NetworkImage.State
        let originalTitle: String
        let plot: String
        let title: String
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

    /// Returns an `IdentifiedArrayOf<Showing.State>` where each `Showing.State` has a unique `title`.
    func filterByUniqueTitles() -> IdentifiedArrayOf<Element> {
        var unique = IdentifiedArrayOf<Element>()

        for showing in self where !unique.contains(where: { $0.title == showing.title }) {
            unique.append(showing)
        }

        return unique
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
