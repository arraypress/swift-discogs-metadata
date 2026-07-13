//
//  DiscogsClient.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Performs GET requests against the Discogs API.
///
/// Discogs **requires** a descriptive `User-Agent`; requests without one are
/// rejected. A personal access token is optional but raises the rate limit
/// (60/min vs 25/min) and unlocks marketplace price suggestions.
enum DiscogsClient {

    static let host = "https://api.discogs.com"

    static func get(
        path: String,
        queryItems: [URLQueryItem] = [],
        configuration: DiscogsMetadata.Configuration
    ) async throws -> [String: Any] {
        guard var components = URLComponents(string: host + path) else {
            throw DiscogsMetadataError.networkError("Invalid request URL")
        }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        guard let url = components.url else {
            throw DiscogsMetadataError.networkError("Invalid request URL")
        }

        var request = URLRequest(url: url)
        request.setValue(configuration.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = configuration.token, !token.isEmpty {
            request.setValue("Discogs token=\(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw DiscogsMetadataError.networkError(error.localizedDescription)
        }

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let message = ((try? JSONSerialization.jsonObject(with: data)) as? [String: Any])?["message"] as? String
            switch http.statusCode {
            case 401: throw DiscogsMetadataError.authenticationRequired
            case 404:
                // Discogs returns 404 for seller-gated endpoints with a telltale message.
                if let message, message.localizedCaseInsensitiveContains("seller settings") {
                    throw DiscogsMetadataError.sellerSettingsRequired
                }
                throw DiscogsMetadataError.notFound
            case 429: throw DiscogsMetadataError.rateLimited
            default: throw DiscogsMetadataError.apiError(message ?? "HTTP \(http.statusCode)")
            }
        }

        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            throw DiscogsMetadataError.parsingError("Invalid JSON response")
        }
        return json
    }
}
