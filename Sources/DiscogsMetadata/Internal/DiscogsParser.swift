//
//  DiscogsParser.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Parses Discogs API response objects into typed models.
enum DiscogsParser {

    /// Canonical Discogs media-condition order, best to worst.
    private static let conditionOrder = [
        "Mint (M)", "Near Mint (NM or M-)", "Very Good Plus (VG+)",
        "Very Good (VG)", "Good Plus (G+)", "Good (G)", "Fair (F)", "Poor (P)"
    ]

    // MARK: - Release

    static func release(_ d: [String: Any]) -> DiscogsRelease {
        let community = d["community"] as? [String: Any]
        let rating = community?["rating"] as? [String: Any]

        return DiscogsRelease(
            id: intValue(d["id"]) ?? 0,
            title: d["title"] as? String ?? "",
            artists: names(d["artists"]),
            year: intValue(d["year"]),
            released: (d["released_formatted"] as? String) ?? (d["released"] as? String),
            genres: stringArray(d["genres"]),
            styles: stringArray(d["styles"]),
            formats: names(d["formats"]),
            labels: names(d["labels"]),
            country: d["country"] as? String,
            tracklist: tracklist(d["tracklist"]),
            thumbnailURL: (d["thumb"] as? String).flatMap { $0.isEmpty ? nil : $0 },
            lowestPrice: doubleValue(d["lowest_price"]),
            numForSale: intValue(d["num_for_sale"]),
            communityRating: doubleValue(rating?["average"]),
            haveCount: intValue(community?["have"]),
            wantCount: intValue(community?["want"]),
            masterID: intValue(d["master_id"]),
            uri: d["uri"] as? String
        )
    }

    private static func tracklist(_ value: Any?) -> [DiscogsTrack] {
        guard let tracks = value as? [[String: Any]] else { return [] }
        return tracks.map {
            DiscogsTrack(
                position: $0["position"] as? String ?? "",
                title: $0["title"] as? String ?? "",
                duration: ($0["duration"] as? String).flatMap { $0.isEmpty ? nil : $0 }
            )
        }
    }

    // MARK: - Search

    static func searchResults(_ d: [String: Any]) -> DiscogsSearchResults {
        let pagination = d["pagination"] as? [String: Any]
        let results = (d["results"] as? [[String: Any]] ?? []).map(searchResult)
        return DiscogsSearchResults(
            results: results,
            page: intValue(pagination?["page"]) ?? 1,
            pages: intValue(pagination?["pages"]) ?? 1,
            totalItems: intValue(pagination?["items"]) ?? results.count,
            perPage: intValue(pagination?["per_page"]) ?? results.count
        )
    }

    private static func searchResult(_ d: [String: Any]) -> DiscogsSearchResult {
        let community = d["community"] as? [String: Any]
        return DiscogsSearchResult(
            id: intValue(d["id"]) ?? 0,
            type: d["type"] as? String ?? "release",
            title: d["title"] as? String ?? "",
            year: (d["year"] as? String).flatMap { $0.isEmpty ? nil : $0 },
            country: d["country"] as? String,
            formats: stringArray(d["format"]),
            labels: stringArray(d["label"]),
            genres: stringArray(d["genre"]),
            styles: stringArray(d["style"]),
            masterID: intValue(d["master_id"]).flatMap { $0 == 0 ? nil : $0 },
            catalogNumber: (d["catno"] as? String).flatMap { $0.isEmpty ? nil : $0 },
            thumbnailURL: (d["thumb"] as? String).flatMap { $0.isEmpty ? nil : $0 },
            coverImageURL: (d["cover_image"] as? String).flatMap { $0.isEmpty ? nil : $0 },
            haveCount: intValue(community?["have"]),
            wantCount: intValue(community?["want"])
        )
    }

    // MARK: - Marketplace

    static func marketStats(_ d: [String: Any]) -> DiscogsMarketStats {
        let lowest = d["lowest_price"] as? [String: Any]
        return DiscogsMarketStats(
            numForSale: intValue(d["num_for_sale"]) ?? 0,
            lowestPrice: doubleValue(lowest?["value"]),
            currency: lowest?["currency"] as? String,
            blockedFromSale: d["blocked_from_sale"] as? Bool ?? false
        )
    }

    static func priceSuggestions(_ d: [String: Any]) -> [DiscogsPriceSuggestion] {
        let suggestions = d.compactMap { key, value -> DiscogsPriceSuggestion? in
            guard let info = value as? [String: Any],
                  let amount = doubleValue(info["value"]) else { return nil }
            return DiscogsPriceSuggestion(
                condition: key,
                value: amount,
                currency: info["currency"] as? String ?? "USD"
            )
        }
        return suggestions.sorted { lhs, rhs in
            let l = conditionOrder.firstIndex(of: lhs.condition) ?? Int.max
            let r = conditionOrder.firstIndex(of: rhs.condition) ?? Int.max
            return l < r
        }
    }

    // MARK: - Master / Artist / Label / User

    static func master(_ d: [String: Any]) -> DiscogsMaster {
        DiscogsMaster(
            id: intValue(d["id"]) ?? 0,
            title: d["title"] as? String ?? "",
            year: intValue(d["year"]),
            artists: names(d["artists"]),
            genres: stringArray(d["genres"]),
            styles: stringArray(d["styles"]),
            mainReleaseID: intValue(d["main_release"]),
            tracklist: tracklist(d["tracklist"]),
            lowestPrice: doubleValue(d["lowest_price"]),
            numForSale: intValue(d["num_for_sale"]),
            imageURL: primaryImage(d["images"]),
            uri: d["uri"] as? String
        )
    }

    static func artist(_ d: [String: Any]) -> DiscogsArtist {
        DiscogsArtist(
            id: intValue(d["id"]) ?? 0,
            name: d["name"] as? String ?? "",
            realName: nonEmpty(d["realname"]),
            profile: nonEmpty(d["profile"]),
            aliases: names(d["aliases"]),
            members: names(d["members"]),
            groups: names(d["groups"]),
            nameVariations: stringArray(d["namevariations"]),
            urls: stringArray(d["urls"]),
            imageURL: primaryImage(d["images"]),
            uri: d["uri"] as? String
        )
    }

    static func label(_ d: [String: Any]) -> DiscogsLabel {
        DiscogsLabel(
            id: intValue(d["id"]) ?? 0,
            name: d["name"] as? String ?? "",
            profile: nonEmpty(d["profile"]),
            contactInfo: nonEmpty(d["contact_info"]),
            parentLabel: (d["parent_label"] as? [String: Any])?["name"] as? String,
            sublabels: names(d["sublabels"]),
            urls: stringArray(d["urls"]),
            imageURL: primaryImage(d["images"]),
            uri: d["uri"] as? String
        )
    }

    static func user(_ d: [String: Any]) -> DiscogsUser {
        DiscogsUser(
            id: intValue(d["id"]) ?? 0,
            username: d["username"] as? String ?? "",
            name: nonEmpty(d["name"]),
            profile: nonEmpty(d["profile"]),
            location: nonEmpty(d["location"]),
            registered: isoDate(d["registered"]),
            rank: doubleValue(d["rank"]),
            numForSale: intValue(d["num_for_sale"]),
            releasesContributed: intValue(d["releases_contributed"]),
            releasesRated: intValue(d["releases_rated"]),
            ratingAvg: doubleValue(d["rating_avg"]),
            sellerRating: doubleValue(d["seller_rating"]),
            buyerRating: doubleValue(d["buyer_rating"]),
            avatarURL: nonEmpty(d["avatar_url"]),
            uri: d["uri"] as? String
        )
    }

    // MARK: - Release summary lists

    /// Parses a versions/releases list. `key` is `"versions"` or `"releases"`.
    static func releaseSummaryPage(_ d: [String: Any], key: String) -> DiscogsPagedResults<DiscogsReleaseSummary> {
        let pagination = d["pagination"] as? [String: Any]
        let items = (d[key] as? [[String: Any]] ?? []).map(releaseSummary)
        return DiscogsPagedResults(
            items: items,
            page: intValue(pagination?["page"]) ?? 1,
            pages: intValue(pagination?["pages"]) ?? 1,
            totalItems: intValue(pagination?["items"]) ?? items.count,
            perPage: intValue(pagination?["per_page"]) ?? items.count
        )
    }

    private static func releaseSummary(_ d: [String: Any]) -> DiscogsReleaseSummary {
        // Year appears as "year" (Int) or "released" (String) across endpoints.
        let year: String? = {
            if let s = nonEmpty(d["year"]) { return s }
            if let i = d["year"] as? Int, i != 0 { return String(i) }
            return nonEmpty(d["released"])
        }()
        return DiscogsReleaseSummary(
            id: intValue(d["id"]) ?? 0,
            title: d["title"] as? String ?? "",
            type: nonEmpty(d["type"]),
            role: nonEmpty(d["role"]),
            artist: nonEmpty(d["artist"]),
            label: nonEmpty(d["label"]),
            catalogNumber: nonEmpty(d["catno"]),
            country: nonEmpty(d["country"]),
            year: year,
            format: nonEmpty(d["format"]),
            status: nonEmpty(d["status"]),
            thumbnailURL: nonEmpty(d["thumb"]),
            mainReleaseID: intValue(d["main_release"]).flatMap { $0 == 0 ? nil : $0 }
        )
    }

    // MARK: - Helpers

    /// The first image URL from a Discogs `images` array.
    private static func primaryImage(_ value: Any?) -> String? {
        guard let images = value as? [[String: Any]] else { return nil }
        return images.first.flatMap { ($0["uri"] as? String) ?? ($0["resource_url"] as? String) }
    }

    /// Returns the string if non-empty, else `nil`. Accepts non-string values as `nil`.
    private static func nonEmpty(_ value: Any?) -> String? {
        guard let s = value as? String, !s.isEmpty else { return nil }
        return s
    }

    private static func isoDate(_ value: Any?) -> Date? {
        guard let s = value as? String else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = formatter.date(from: s) { return d }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: s)
    }

    /// Extracts `name` strings from arrays of `{ "name": ... }` objects.
    private static func names(_ value: Any?) -> [String] {
        guard let array = value as? [[String: Any]] else { return [] }
        return array.compactMap { $0["name"] as? String }
    }

    private static func stringArray(_ value: Any?) -> [String] {
        value as? [String] ?? []
    }

    private static func intValue(_ value: Any?) -> Int? {
        if let i = value as? Int { return i }
        if let s = value as? String { return Int(s) }
        if let d = value as? Double { return Int(d) }
        return nil
    }

    private static func doubleValue(_ value: Any?) -> Double? {
        if let d = value as? Double { return d }
        if let i = value as? Int { return Double(i) }
        if let s = value as? String { return Double(s) }
        return nil
    }
}
