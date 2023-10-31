//
//  Venue.swift
//  Cinema
//
//  Created by Marius on 2021-07-27.
//  Copyright © 2021 Marius. All rights reserved.
//

import Foundation

enum Venue: String, CaseIterable, Codable, Identifiable {
    var id: Self { self }

    case apollo
    case apolloAkropolis
    case apolloOutlet
    case atlantis
    case cinamon
    case forum
    case multikino
}
