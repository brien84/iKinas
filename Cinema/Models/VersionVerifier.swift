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
        session.dataTask(with: .update) { data, _, error in
            if error != nil {
                completion(.failure(.verificationFailure))
                return
            }

            guard let data else {
                completion(.failure(.verificationFailure))
                return
            }

            guard let requiredVersion = try? JSONDecoder().decode(Double.self, from: data) else {
                completion(.failure(.verificationFailure))
                return
            }

            guard let systemVersion = Double(UIDevice.current.systemVersion) else {
                completion(.failure(.verificationFailure))
                return
            }

            if systemVersion > requiredVersion {
                completion(.success(()))
            } else {
                completion(.failure(.requiresUpdate))
            }
        }.resume()
    }
}
