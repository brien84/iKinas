//
//  APIClient.swift
//  Cinema
//
//  Created by Marius on 2023-06-30.
//  Copyright © 2023 Marius. All rights reserved.
//

import Foundation

struct APIClient {

}

extension APIClient: TestDependencyKey {
    static let testValue = Self()

    static let previewValue = Self()
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
