//
//  Extension+Bundle.swift
//  Cinema
//
//  Created by Marius on 2023-10-29.
//  Copyright © 2023 Marius. All rights reserved.
//

import Foundation

extension Bundle {
    var build: String? {
        self.infoDictionary?["CFBundleVersion"] as? String
    }

    var version: String? {
        self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
