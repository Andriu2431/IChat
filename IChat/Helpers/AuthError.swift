//
//  AuthError.swift
//  IChat
//
//  Created by Andrii Malyk on 13.09.2022.
//

import Foundation

// енум помилок при рейстрації
enum AuthError {
    case notFilled
    case invalidEmail
    case passwordNotMatched
    case unknownError
    case serverError
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Fill in all fields", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Incorrect email", comment: "")
        case .passwordNotMatched:
            return NSLocalizedString("Passwords do not match", comment: "")
        case .unknownError:
            return NSLocalizedString("Unknown error", comment: "")
        case .serverError:
            return NSLocalizedString("Server error", comment: "")
        }
    }
}
