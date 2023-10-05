//
//  City.swift
//  Cinema
//
//  Created by Marius on 2020-02-10.
//  Copyright © 2020 Marius. All rights reserved.
//

import OrderedCollections

enum City: String, CaseIterable, Codable, CustomStringConvertible, Identifiable {
    var id: Self { self }

    case vilnius
    case kaunas
    case klaipeda
    case siauliai
    case panevezys

    var venues: OrderedSet<Venue> {
        switch self {
        case .vilnius:
            return [.apollo, .forum, .multikino]
        case .kaunas:
            return [.cinamon, .forum]
        case .klaipeda:
            return [.forum]
        case .siauliai:
            return [.atlantis, .forum]
        case .panevezys:
            return [.apollo]
        }
    }

    var description: String {
        switch self {
        case .vilnius:
            return "Vilnius"
        case .kaunas:
            return "Kaunas"
        case .klaipeda:
            return "Klaipėda"
        case .siauliai:
            return "Šiauliai"
        case .panevezys:
            return "Panevėžys"
        }
    }
}
