//
//  DiscogsMetadataError.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Errors that can occur when calling the Discogs API.
public enum DiscogsMetadataError: Error, LocalizedError, Equatable, Sendable {

    /// The provided input could not be parsed into a release ID or query.
    case invalidInput

    /// The requested resource was not found (`404`).
    case notFound

    /// The endpoint requires authentication and no valid token was supplied,
    /// or the token was rejected (`401`).
    ///
    /// Notably, marketplace price suggestions require a personal access token.
    case authenticationRequired

    /// Discogs is rate-limiting requests (`429`). Authenticated requests get a
    /// higher limit (60/min vs 25/min).
    case rateLimited

    /// A seller-only endpoint (e.g. price suggestions) was called by an account
    /// that hasn't completed its Discogs seller settings.
    case sellerSettingsRequired

    /// Discogs returned an error payload.
    case apiError(String)

    /// A network request failed.
    case networkError(String)

    /// Failed to parse the response.
    case parsingError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Could not parse a Discogs release ID or query from the input."
        case .notFound:
            return "The requested Discogs resource was not found."
        case .authenticationRequired:
            return "This Discogs endpoint requires a personal access token (set DISCOGS_TOKEN or pass one in the configuration)."
        case .rateLimited:
            return "Discogs is rate-limiting requests. Authenticated requests get 60/min vs 25/min."
        case .sellerSettingsRequired:
            return "Discogs price suggestions require seller settings on your account. Fill them out at discogs.com to use this endpoint."
        case .apiError(let message):
            return "Discogs API error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
}
