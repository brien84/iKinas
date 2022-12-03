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

    case apollo = "Apollo"
    case cinamon = "Cinamon"
    case forum = "Forum Cinemas"
    case multikino = "Multikino"
}
