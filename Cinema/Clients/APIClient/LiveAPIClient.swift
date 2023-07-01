//
//  LiveAPIClient.swift
//  Cinema
//
//  Created by Marius on 2023-06-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import Foundation

extension APIClient: DependencyKey {
    static var liveValue: Self {
        return Self()
    }
}
