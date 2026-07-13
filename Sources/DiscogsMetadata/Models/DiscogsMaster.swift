//
//  DiscogsMaster.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A Discogs master release — the canonical entry that groups all the
/// individual pressings/editions (``DiscogsRelease``) of a recording.
///
/// ```swift
/// let master = try await DiscogsMetadata.master(96559)
/// let versions = try await DiscogsMetadata.masterVersions(masterID: 96559)
/// ```
public struct DiscogsMaster: Sendable, Identifiable {
    /// The master release ID.
    public let id: Int
    /// The title.
    public let title: String
    /// The year of the earliest release, if known.
    public let year: Int?
    /// The credited artists' names.
    public let artists: [String]
    /// Genres.
    public let genres: [String]
    /// Styles/subgenres.
    public let styles: [String]
    /// The "main" (definitive) release ID for this master.
    public let mainReleaseID: Int?
    /// The tracklist.
    public let tracklist: [DiscogsTrack]
    /// The lowest current marketplace price across all versions.
    public let lowestPrice: Double?
    /// The number of copies (across versions) currently for sale.
    public let numForSale: Int?
    /// A primary image URL.
    public let imageURL: String?
    /// The Discogs page URI.
    public let uri: String?

    /// The credited artists joined for display.
    public var artistNames: String { artists.joined(separator: ", ") }

    public init(
        id: Int, title: String, year: Int?, artists: [String], genres: [String],
        styles: [String], mainReleaseID: Int?, tracklist: [DiscogsTrack],
        lowestPrice: Double?, numForSale: Int?, imageURL: String?, uri: String?
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.artists = artists
        self.genres = genres
        self.styles = styles
        self.mainReleaseID = mainReleaseID
        self.tracklist = tracklist
        self.lowestPrice = lowestPrice
        self.numForSale = numForSale
        self.imageURL = imageURL
        self.uri = uri
    }
}
