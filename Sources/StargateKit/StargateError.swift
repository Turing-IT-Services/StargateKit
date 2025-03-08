//
//  StargateError.swift
//  StargateKit
//
//  Created by Murilo Araujo on 08/03/25.
//

import Foundation

/// Errors thrown by StargateKit during request processing.
public enum StargateError: Error, LocalizedError {
    /// Indicates that no request performer was found in the chain for the given URL.
    case noRequestPerformer(url: String)

    /// Indicates that multiple matching routes were found (if ambiguous routes are not allowed).
    case ambiguousRoute(url: String, count: Int)

    public var errorDescription: String? {
        switch self {
        case .noRequestPerformer(let url):
            return "No request performer found for URL: \(url)"
        case .ambiguousRoute(let url, let count):
            return "Ambiguous route match for URL: \(url). Found \(count) matching modifiers."
        }
    }
}
