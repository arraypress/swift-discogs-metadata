//
//  DiscogsSearchType.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The type of Discogs database entity to search for.
public enum DiscogsSearchType: String, Sendable {
    /// A specific release (a particular pressing/edition).
    case release
    /// A master release (the canonical version grouping its editions).
    case master
    /// An artist.
    case artist
    /// A label.
    case label
}
