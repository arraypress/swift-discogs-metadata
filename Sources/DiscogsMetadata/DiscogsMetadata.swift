//
//  DiscogsMetadata.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Fetch release metadata, search the Discogs database, and read marketplace
/// prices for music (records, CDs, cassettes).
///
/// Most of the Discogs API is usable **without a token** (release/master/artist
/// lookups, search, and marketplace stats including the lowest current price).
/// A free **personal access token** raises the rate limit (60/min vs 25/min)
/// and unlocks per-condition ``priceSuggestions(releaseID:configuration:)``.
///
/// Discogs requires a descriptive `User-Agent`; a default is provided and can be
/// overridden in ``Configuration``.
///
/// ```swift
/// import DiscogsMetadata
///
/// let release = try await DiscogsMetadata.release(249504)
/// print("\(release.artistNames) – \(release.title) — from \(release.lowestPrice ?? 0), \(release.numForSale ?? 0) for sale")
///
/// let results = try await DiscogsMetadata.search("nirvana nevermind", type: .release)
/// let stats = try await DiscogsMetadata.marketplaceStats(releaseID: 249504, currency: "GBP")
/// ```
public enum DiscogsMetadata {

    // MARK: - Configuration

    /// Options for talking to the Discogs API.
    public struct Configuration: Sendable {

        /// A personal access token. Optional, but raises the rate limit and
        /// enables marketplace price suggestions.
        public var token: String?

        /// The `User-Agent` sent with every request. Discogs requires a
        /// descriptive one; the default identifies this library.
        public var userAgent: String

        /// Default currency for marketplace endpoints (e.g. `"USD"`, `"GBP"`).
        public var currency: String

        public init(
            token: String? = nil,
            userAgent: String = "swift-discogs-metadata/1.0 +https://github.com/arraypress",
            currency: String = "USD"
        ) {
            self.token = token
            self.userAgent = userAgent
            self.currency = currency
        }

        /// Reads `DISCOGS_TOKEN` (and optional `DISCOGS_CURRENCY`) from the environment.
        public static var `default`: Configuration {
            let env = ProcessInfo.processInfo.environment
            return Configuration(
                token: env["DISCOGS_TOKEN"],
                currency: env["DISCOGS_CURRENCY"] ?? "USD"
            )
        }
    }

    // MARK: - Public API

    /// Fetches a release by its Discogs ID.
    public static func release(
        _ id: Int,
        configuration: Configuration = .default
    ) async throws -> DiscogsRelease {
        let data = try await DiscogsClient.get(path: "/releases/\(id)", configuration: configuration)
        return DiscogsParser.release(data)
    }

    /// Searches the Discogs database.
    ///
    /// - Parameters:
    ///   - query: Free-text query.
    ///   - type: Restrict to a type (release, master, artist, label).
    ///   - genre/style/year/format/country: Optional filters.
    ///   - page/perPage: Pagination (Discogs caps `perPage` at 100).
    public static func search(
        _ query: String,
        type: DiscogsSearchType? = nil,
        genre: String? = nil,
        style: String? = nil,
        year: String? = nil,
        format: String? = nil,
        country: String? = nil,
        page: Int = 1,
        perPage: Int = 50,
        configuration: Configuration = .default
    ) async throws -> DiscogsSearchResults {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(min(perPage, 100)))
        ]
        if let type { items.append(URLQueryItem(name: "type", value: type.rawValue)) }
        if let genre { items.append(URLQueryItem(name: "genre", value: genre)) }
        if let style { items.append(URLQueryItem(name: "style", value: style)) }
        if let year { items.append(URLQueryItem(name: "year", value: year)) }
        if let format { items.append(URLQueryItem(name: "format", value: format)) }
        if let country { items.append(URLQueryItem(name: "country", value: country)) }

        let data = try await DiscogsClient.get(
            path: "/database/search", queryItems: items, configuration: configuration
        )
        return DiscogsParser.searchResults(data)
    }

    /// Fetches marketplace statistics (number for sale + lowest price) for a release.
    public static func marketplaceStats(
        releaseID: Int,
        currency: String? = nil,
        configuration: Configuration = .default
    ) async throws -> DiscogsMarketStats {
        let items = [URLQueryItem(name: "curr_abbr", value: currency ?? configuration.currency)]
        let data = try await DiscogsClient.get(
            path: "/marketplace/stats/\(releaseID)", queryItems: items, configuration: configuration
        )
        return DiscogsParser.marketStats(data)
    }

    /// Fetches suggested marketplace prices per media condition for a release.
    ///
    /// **Requires a personal access token** — throws
    /// ``DiscogsMetadataError/authenticationRequired`` if none is configured.
    ///
    /// This is a **seller** tool: Discogs only returns suggestions to accounts
    /// that have completed their seller settings. Accounts that haven't get
    /// ``DiscogsMetadataError/sellerSettingsRequired``. All other endpoints
    /// (release, search, marketplace stats) work without seller status.
    public static func priceSuggestions(
        releaseID: Int,
        configuration: Configuration = .default
    ) async throws -> [DiscogsPriceSuggestion] {
        guard let token = configuration.token, !token.isEmpty else {
            throw DiscogsMetadataError.authenticationRequired
        }
        _ = token
        let data = try await DiscogsClient.get(
            path: "/marketplace/price_suggestions/\(releaseID)", configuration: configuration
        )
        return DiscogsParser.priceSuggestions(data)
    }

    // MARK: - Database entities

    /// Fetches a master release (the canonical entry grouping all its editions).
    public static func master(
        _ id: Int, configuration: Configuration = .default
    ) async throws -> DiscogsMaster {
        let data = try await DiscogsClient.get(path: "/masters/\(id)", configuration: configuration)
        return DiscogsParser.master(data)
    }

    /// Fetches the versions (individual pressings/editions) of a master release.
    public static func masterVersions(
        masterID: Int, page: Int = 1, perPage: Int = 50, configuration: Configuration = .default
    ) async throws -> DiscogsPagedResults<DiscogsReleaseSummary> {
        let items = pageItems(page: page, perPage: perPage)
        let data = try await DiscogsClient.get(
            path: "/masters/\(masterID)/versions", queryItems: items, configuration: configuration
        )
        return DiscogsParser.releaseSummaryPage(data, key: "versions")
    }

    /// Fetches an artist.
    public static func artist(
        _ id: Int, configuration: Configuration = .default
    ) async throws -> DiscogsArtist {
        let data = try await DiscogsClient.get(path: "/artists/\(id)", configuration: configuration)
        return DiscogsParser.artist(data)
    }

    /// Fetches an artist's releases (discography).
    public static func artistReleases(
        artistID: Int, page: Int = 1, perPage: Int = 50, configuration: Configuration = .default
    ) async throws -> DiscogsPagedResults<DiscogsReleaseSummary> {
        let items = pageItems(page: page, perPage: perPage)
        let data = try await DiscogsClient.get(
            path: "/artists/\(artistID)/releases", queryItems: items, configuration: configuration
        )
        return DiscogsParser.releaseSummaryPage(data, key: "releases")
    }

    /// Fetches a label.
    public static func label(
        _ id: Int, configuration: Configuration = .default
    ) async throws -> DiscogsLabel {
        let data = try await DiscogsClient.get(path: "/labels/\(id)", configuration: configuration)
        return DiscogsParser.label(data)
    }

    /// Fetches a label's releases (catalog).
    public static func labelReleases(
        labelID: Int, page: Int = 1, perPage: Int = 50, configuration: Configuration = .default
    ) async throws -> DiscogsPagedResults<DiscogsReleaseSummary> {
        let items = pageItems(page: page, perPage: perPage)
        let data = try await DiscogsClient.get(
            path: "/labels/\(labelID)/releases", queryItems: items, configuration: configuration
        )
        return DiscogsParser.releaseSummaryPage(data, key: "releases")
    }

    /// Fetches a public user profile.
    public static func user(
        _ username: String, configuration: Configuration = .default
    ) async throws -> DiscogsUser {
        let data = try await DiscogsClient.get(path: "/users/\(username)", configuration: configuration)
        return DiscogsParser.user(data)
    }

    // MARK: - Helpers

    private static func pageItems(page: Int, perPage: Int) -> [URLQueryItem] {
        [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(min(perPage, 100)))
        ]
    }
}
