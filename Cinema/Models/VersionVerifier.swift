//
//  VersionVerifier.swift
//  Cinema
//
//  Created by Marius on 2022-11-20.
//  Copyright © 2022 Marius. All rights reserved.
//

import UIKit

protocol VersionVerification {
    func verifyVersion(using session: URLSession, completion: @escaping (Result<Void, VersionVerifier.VersionError>) -> Void)
}

final class VersionVerifier: VersionVerification {
    enum VersionError: Error {
        case verificationFailure
        case requiresUpdate
    }

    func verifyVersion(using session: URLSession = .shared, completion: @escaping (Result<Void, VersionError>) -> Void) {

    }
}
