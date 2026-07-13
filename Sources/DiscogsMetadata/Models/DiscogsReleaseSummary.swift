//
//  DiscogsReleaseSummary.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A lightweight release entry as it appears in a master's versions list or an
/// artist's / label's discography.
public struct DiscogsReleaseSummary: Sendable, Identifiable {
    /// The release ID.
    public let id: Int
    /// The release title.
    public let title: String
    /// The entity type (`"release"` or `"master"`), where provided.
    public let type: String?
    /// The artist's role (e.g. `"Main"`, `"Remix"`), for artist discographies.
    public let role: String?
    /// The credited artist string, where provided.
    public let artist: String?
    /// The label string, where provided.
    public let label: String?
    /// The catalogue number.
    public let catalogNumber: String?
    /// The country of release.
    public let country: String?
    /// The year/date as text (e.g. `"1987"`).
    public let year: String?
    /// The format descriptor (e.g. `"12\", 33 ⅓ RPM, Maxi-Single"`).
    public let format: String?
    /// The submission status (e.g. `"Accepted"`).
    public let status: String?
    /// A thumbnail image URL.
    public let thumbnailURL: String?
    /// For a `master`-typed entry, its main release ID.
    public let mainReleaseID: Int?

    public init(
        id: Int, title: String, type: String?, role: String?, artist: String?,
        label: String?, catalogNumber: String?, country: String?, year: String?,
        format: String?, status: String?, thumbnailURL: String?, mainReleaseID: Int?
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.role = role
        self.artist = artist
        self.label = label
        self.catalogNumber = catalogNumber
        self.country = country
        self.year = year
        self.format = format
        self.status = status
        self.thumbnailURL = thumbnailURL
        self.mainReleaseID = mainReleaseID
    }
}

/// A paginated list of items from a Discogs list endpoint.
public struct DiscogsPagedResults<Element: Sendable>: Sendable {
    /// The items on this page.
    public let items: [Element]
    /// The current page (1-based).
    public let page: Int
    /// The total number of pages.
    public let pages: Int
    /// The total number of items across all pages.
    public let totalItems: Int
    /// The number of items per page.
    public let perPage: Int

    /// Whether another page is available.
    public var hasNextPage: Bool { page < pages }

    public init(items: [Element], page: Int, pages: Int, totalItems: Int, perPage: Int) {
        self.items = items
        self.page = page
        self.pages = pages
        self.totalItems = totalItems
        self.perPage = perPage
    }
}
