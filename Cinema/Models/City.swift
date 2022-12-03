//
//  City.swift
//  Cinema
//
//  Created by Marius on 2020-02-10.
//  Copyright © 2020 Marius. All rights reserved.
//

import OrderedCollections

enum City: String, CaseIterable, Codable, Identifiable {
    var id: Self { self }

    case vilnius = "Vilnius"
    case kaunas = "Kaunas"
    case klaipeda = "Klaipėda"
    case siauliai = "Šiauliai"
    case panevezys = "Panevėžys"

    var venues: OrderedSet<Venue> {
        switch self {
        case .vilnius:
            return [.apollo, .forum, .multikino]
        case .kaunas:
            return [.cinamon, .forum]
        case .klaipeda:
            return [.forum]
        case .siauliai:
            return [.forum]
        case .panevezys:
            return [.apollo]
        }
    }
}
