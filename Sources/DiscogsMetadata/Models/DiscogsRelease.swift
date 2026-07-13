//
//  DiscogsRelease.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A track on a Discogs release.
public struct DiscogsTrack: Sendable, Equatable {
    /// The track position (e.g. `"A1"`, `"2"`).
    public let position: String
    /// The track title.
    public let title: String
    /// The track duration (e.g. `"3:32"`), if listed.
    public let duration: String?

    public init(position: String, title: String, duration: String?) {
        self.position = position
        self.title = title
        self.duration = duration
    }
}

/// A Discogs release — a specific pressing/edition of a record, CD, etc.
///
/// Includes the marketplace price snapshot (``lowestPrice`` / ``numForSale``)
/// that Discogs returns inline, so no extra request is needed for a headline price.
///
/// ```swift
/// let release = try await DiscogsMetadata.release(249504)
/// print("\(release.artistNames) – \(release.title) (\(release.year ?? 0))")
/// if let low = release.lowestPrice { print("from \(low) · \(release.numForSale ?? 0) for sale") }
/// ```
public struct DiscogsRelease: Sendable, Identifiable {

    /// The Discogs release ID.
    public let id: Int

    /// The release title.
    public let title: String

    /// The credited artists' names.
    public let artists: [String]

    /// The release year, if known.
    public let year: Int?

    /// The formatted release date (e.g. `"1987"`, `"27 Jul 1987"`), if present.
    public let released: String?

    /// Genres (e.g. `["Electronic", "Pop"]`).
    public let genres: [String]

    /// Styles/subgenres (e.g. `["Synth-pop"]`).
    public let styles: [String]

    /// Format names (e.g. `["Vinyl", "7\"", "45 RPM"]`).
    public let formats: [String]

    /// Label names.
    public let labels: [String]

    /// The country of release.
    public let country: String?

    /// The tracklist.
    public let tracklist: [DiscogsTrack]

    /// A thumbnail image URL, if available.
    public let thumbnailURL: String?

    /// The lowest current marketplace price, if any items are for sale.
    public let lowestPrice: Double?

    /// The number of copies currently listed for sale.
    public let numForSale: Int?

    /// The community's average rating (0–5), if rated.
    public let communityRating: Double?

    /// How many community members have this release.
    public let haveCount: Int?

    /// How many community members want this release.
    public let wantCount: Int?

    /// The master release ID this belongs to, if any.
    public let masterID: Int?

    /// The Discogs page URI for this release.
    public let uri: String?

    /// The credited artists joined for display (e.g. `"Simon & Garfunkel"`).
    public var artistNames: String { artists.joined(separator: ", ") }

    public init(
        id: Int, title: String, artists: [String], year: Int?, released: String?,
        genres: [String], styles: [String], formats: [String], labels: [String],
        country: String?, tracklist: [DiscogsTrack], thumbnailURL: String?,
        lowestPrice: Double?, numForSale: Int?, communityRating: Double?,
        haveCount: Int?, wantCount: Int?, masterID: Int?, uri: String?
    ) {
        self.id = id
        self.title = title
        self.artists = artists
        self.year = year
        self.released = released
        self.genres = genres
        self.styles = styles
        self.formats = formats
        self.labels = labels
        self.country = country
        self.tracklist = tracklist
        self.thumbnailURL = thumbnailURL
        self.lowestPrice = lowestPrice
        self.numForSale = numForSale
        self.communityRating = communityRating
        self.haveCount = haveCount
        self.wantCount = wantCount
        self.masterID = masterID
        self.uri = uri
    }
}
