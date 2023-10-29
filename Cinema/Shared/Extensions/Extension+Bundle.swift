//
//  Extension+Bundle.swift
//  Cinema
//
//  Created by Marius on 2023-10-29.
//  Copyright © 2023 Marius. All rights reserved.
//

import Foundation

extension Bundle {
    var build: String {
        guard let build = self.infoDictionary?["CFBundleVersion"] as? String
        else { fatalError("build not found!") }
        return build
    }

    var version: String {
        guard let version = self.infoDictionary?["CFBundleShortVersionString"] as? String
        else { fatalError("version not found!") }
        return version
    }
}
