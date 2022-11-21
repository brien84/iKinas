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
        let task = session.dataTask(with: .update) { data, _, error in
            if error != nil {
                completion(.failure(.verificationFailure))
                return
            }

            guard let data else {
                completion(.failure(.verificationFailure))
                return
            }

            let requiredVersion = String(decoding: data, as: UTF8.self)

            guard let currentVersion = Bundle.main.appVersion else {
                fatalError("App Version not found!")
            }

            switch requiredVersion.compare(currentVersion, options: .numeric) {
            case .orderedAscending:
                completion(.success(()))
                return
            case .orderedSame:
                completion(.success(()))
                return
            case .orderedDescending:
                completion(.failure(.requiresUpdate))
                return
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            task.resume()
        }
    }
}

private extension Bundle {
    var appVersion: String? {
        self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
