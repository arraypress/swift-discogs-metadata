//
//  DiscogsEntities.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A Discogs artist.
public struct DiscogsArtist: Sendable, Identifiable {
    /// The artist ID.
    public let id: Int
    /// The artist name.
    public let name: String
    /// The artist's real name, where known.
    public let realName: String?
    /// The biography/profile text.
    public let profile: String?
    /// Alias names.
    public let aliases: [String]
    /// Member names (for groups/bands).
    public let members: [String]
    /// Group names this artist belongs to.
    public let groups: [String]
    /// Name variations.
    public let nameVariations: [String]
    /// External URLs.
    public let urls: [String]
    /// A primary image URL.
    public let imageURL: String?
    /// The Discogs page URI.
    public let uri: String?

    public init(
        id: Int, name: String, realName: String?, profile: String?, aliases: [String],
        members: [String], groups: [String], nameVariations: [String], urls: [String],
        imageURL: String?, uri: String?
    ) {
        self.id = id; self.name = name; self.realName = realName; self.profile = profile
        self.aliases = aliases; self.members = members; self.groups = groups
        self.nameVariations = nameVariations; self.urls = urls; self.imageURL = imageURL; self.uri = uri
    }
}

/// A Discogs label.
public struct DiscogsLabel: Sendable, Identifiable {
    /// The label ID.
    public let id: Int
    /// The label name.
    public let name: String
    /// The label profile/description.
    public let profile: String?
    /// Contact information text.
    public let contactInfo: String?
    /// The parent label name, if this is a sublabel.
    public let parentLabel: String?
    /// Sublabel names.
    public let sublabels: [String]
    /// External URLs.
    public let urls: [String]
    /// A primary image URL.
    public let imageURL: String?
    /// The Discogs page URI.
    public let uri: String?

    public init(
        id: Int, name: String, profile: String?, contactInfo: String?, parentLabel: String?,
        sublabels: [String], urls: [String], imageURL: String?, uri: String?
    ) {
        self.id = id; self.name = name; self.profile = profile; self.contactInfo = contactInfo
        self.parentLabel = parentLabel; self.sublabels = sublabels; self.urls = urls
        self.imageURL = imageURL; self.uri = uri
    }
}

/// A public Discogs user profile.
public struct DiscogsUser: Sendable, Identifiable {
    /// The user's numeric ID.
    public let id: Int
    /// The username.
    public let username: String
    /// The display name, where set.
    public let name: String?
    /// The profile text.
    public let profile: String?
    /// The user's location, where set.
    public let location: String?
    /// When the account was registered.
    public let registered: Date?
    /// The contributor rank.
    public let rank: Double?
    /// The number of items the user currently has for sale.
    public let numForSale: Int?
    /// The number of releases the user has contributed.
    public let releasesContributed: Int?
    /// The number of releases the user has rated.
    public let releasesRated: Int?
    /// The user's average rating given.
    public let ratingAvg: Double?
    /// The user's seller rating, if a seller.
    public let sellerRating: Double?
    /// The user's buyer rating.
    public let buyerRating: Double?
    /// The avatar image URL.
    public let avatarURL: String?
    /// The Discogs page URI.
    public let uri: String?

    public init(
        id: Int, username: String, name: String?, profile: String?, location: String?,
        registered: Date?, rank: Double?, numForSale: Int?, releasesContributed: Int?,
        releasesRated: Int?, ratingAvg: Double?, sellerRating: Double?, buyerRating: Double?,
        avatarURL: String?, uri: String?
    ) {
        self.id = id; self.username = username; self.name = name; self.profile = profile
        self.location = location; self.registered = registered; self.rank = rank
        self.numForSale = numForSale; self.releasesContributed = releasesContributed
        self.releasesRated = releasesRated; self.ratingAvg = ratingAvg
        self.sellerRating = sellerRating; self.buyerRating = buyerRating
        self.avatarURL = avatarURL; self.uri = uri
    }
}
