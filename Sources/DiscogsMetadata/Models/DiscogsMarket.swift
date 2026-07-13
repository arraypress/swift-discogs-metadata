//
//  DiscogsMarket.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Marketplace statistics for a Discogs release.
///
/// Returned by ``DiscogsMetadata/marketplaceStats(releaseID:currency:configuration:)``.
public struct DiscogsMarketStats: Sendable {
    /// The number of copies currently listed for sale.
    public let numForSale: Int
    /// The lowest current asking price, if any copies are for sale.
    public let lowestPrice: Double?
    /// The currency of ``lowestPrice`` (e.g. `"USD"`, `"GBP"`).
    public let currency: String?
    /// Whether the release is blocked from sale on the marketplace.
    public let blockedFromSale: Bool

    public init(numForSale: Int, lowestPrice: Double?, currency: String?, blockedFromSale: Bool) {
        self.numForSale = numForSale
        self.lowestPrice = lowestPrice
        self.currency = currency
        self.blockedFromSale = blockedFromSale
    }
}

/// A suggested marketplace price for a release in a specific media condition.
///
/// Returned by ``DiscogsMetadata/priceSuggestions(releaseID:configuration:)``,
/// which **requires a personal access token**.
public struct DiscogsPriceSuggestion: Sendable, Identifiable {
    /// The media condition, e.g. `"Mint (M)"`, `"Near Mint (NM or M-)"`, `"Very Good Plus (VG+)"`.
    public let condition: String
    /// The suggested price value.
    public let value: Double
    /// The currency (e.g. `"USD"`).
    public let currency: String

    /// The condition doubles as a stable identifier.
    public var id: String { condition }

    public init(condition: String, value: Double, currency: String) {
        self.condition = condition
        self.value = value
        self.currency = currency
    }
}
