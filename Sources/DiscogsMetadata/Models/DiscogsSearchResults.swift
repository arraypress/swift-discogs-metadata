//
//  DiscogsSearchResults.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A single Discogs database search hit.
public struct DiscogsSearchResult: Sendable, Identifiable {
    /// The entity ID.
    public let id: Int
    /// The entity type (`"release"`, `"master"`, `"artist"`, `"label"`).
    public let type: String
    /// The result title (often `"Artist - Title"`).
    public let title: String
    /// The year as text (may be empty), e.g. `"1991"`.
    public let year: String?
    /// The country of release.
    public let country: String?
    /// Format descriptors (e.g. `["Vinyl", "LP", "Album"]`).
    public let formats: [String]
    /// Label names.
    public let labels: [String]
    /// Genres.
    public let genres: [String]
    /// Styles/subgenres.
    public let styles: [String]
    /// The master release ID, if applicable.
    public let masterID: Int?
    /// The catalogue number.
    public let catalogNumber: String?
    /// A thumbnail image URL.
    public let thumbnailURL: String?
    /// A cover image URL.
    public let coverImageURL: String?
    /// How many community members have it.
    public let haveCount: Int?
    /// How many community members want it.
    public let wantCount: Int?

    public init(
        id: Int, type: String, title: String, year: String?, country: String?,
        formats: [String], labels: [String], genres: [String], styles: [String],
        masterID: Int?, catalogNumber: String?, thumbnailURL: String?,
        coverImageURL: String?, haveCount: Int?, wantCount: Int?
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.year = year
        self.country = country
        self.formats = formats
        self.labels = labels
        self.genres = genres
        self.styles = styles
        self.masterID = masterID
        self.catalogNumber = catalogNumber
        self.thumbnailURL = thumbnailURL
        self.coverImageURL = coverImageURL
        self.haveCount = haveCount
        self.wantCount = wantCount
    }
}

/// A page of Discogs search results with pagination metadata.
public struct DiscogsSearchResults: Sendable {
    /// The results on this page.
    public let results: [DiscogsSearchResult]
    /// The current page (1-based).
    public let page: Int
    /// The total number of pages.
    public let pages: Int
    /// The total number of matching items.
    public let totalItems: Int
    /// The number of results per page.
    public let perPage: Int

    /// Whether another page is available.
    public var hasNextPage: Bool { page < pages }

    public init(results: [DiscogsSearchResult], page: Int, pages: Int, totalItems: Int, perPage: Int) {
        self.results = results
        self.page = page
        self.pages = pages
        self.totalItems = totalItems
        self.perPage = perPage
    }
}
