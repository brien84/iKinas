//
//  ShowingItem.swift
//  Cinema
//
//  Created by Marius on 2023-08-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct ShowingItem: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID { showing.id }
        let showing: Showing
        var networkImage: NetworkImage.State

        init?(showing: Showing) {
            self.showing = showing
            self.networkImage = NetworkImage.State(url: showing.posterURL)
        }
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

extension IdentifiedArrayOf where Element == ShowingItem.State, ID == UUID {
    func filter(by date: Date) -> IdentifiedArrayOf<Element> {
        self.filter { item in
            Calendar.current.isDate(item.showing.date, inSameDayAs: date)
        }
    }

    func getUniqueTitles() -> IdentifiedArrayOf<Element> {
        var unique = IdentifiedArrayOf<Element>()

        for item in self where !unique.contains(where: { $0.showing.title == item.showing.title }) {
            unique.append(item)
        }

        return unique
    }

    mutating func sort(by option: ShowingItem.SortOption) {
        switch option {
        case .date:
            self.sort(by: { $0.showing < $1.showing })
            return
        case .title:
            self.sort(by: {
                $0.showing.title.compare($1.showing.title, locale: ShowingItem.locale) == .orderedAscending
            })
            return
        }
    }
}

extension ShowingItem {
    fileprivate static let locale = Locale(identifier: "lt")

    enum SortOption {
        case title
        case date
    }
}
