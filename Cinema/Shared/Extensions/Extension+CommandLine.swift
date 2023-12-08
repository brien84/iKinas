//
//  Extension+CommandLine.swift
//  Cinema
//
//  Created by Marius on 2023-12-08.
//  Copyright © 2023 Marius. All rights reserved.
//

import Foundation

extension CommandLine {
    static var isUITesting: Bool {
        Self.arguments.contains("ui-testing")
    }
}
