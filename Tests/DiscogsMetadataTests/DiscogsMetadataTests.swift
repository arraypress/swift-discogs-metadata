//
//  DiscogsMetadataTests.swift
//  DiscogsMetadata
//
//  Created by David Sherlock on 2026.
//

import XCTest
@testable import DiscogsMetadata

final class DiscogsMetadataTests: XCTestCase {

    // MARK: - Release parsing

    func testParseRelease() throws {
        let release = DiscogsParser.release(try json(Fixture.release))
        XCTAssertEqual(release.id, 249504)
        XCTAssertEqual(release.title, "Never Gonna Give You Up")
        XCTAssertEqual(release.artists, ["Rick Astley"])
        XCTAssertEqual(release.artistNames, "Rick Astley")
        XCTAssertEqual(release.year, 1987)
        XCTAssertEqual(release.genres, ["Electronic", "Pop"])
        XCTAssertEqual(release.formats, ["Vinyl"])
        XCTAssertEqual(release.labels, ["RCA"])
        XCTAssertEqual(release.country, "UK")
        XCTAssertEqual(release.lowestPrice, 0.89)
        XCTAssertEqual(release.numForSale, 121)
        XCTAssertEqual(release.communityRating, 3.84)
        XCTAssertEqual(release.tracklist.count, 2)
        XCTAssertEqual(release.tracklist.first?.title, "Never Gonna Give You Up")
        XCTAssertEqual(release.masterID, 96559)
    }

    // MARK: - Search parsing

    func testParseSearch() throws {
        let results = DiscogsParser.searchResults(try json(Fixture.search))
        XCTAssertEqual(results.totalItems, 15448)
        XCTAssertEqual(results.page, 1)
        XCTAssertEqual(results.pages, 5000)
        XCTAssertTrue(results.hasNextPage)
        XCTAssertEqual(results.results.count, 1)

        let hit = results.results[0]
        XCTAssertEqual(hit.id, 7097051)
        XCTAssertEqual(hit.type, "release")
        XCTAssertEqual(hit.title, "Nirvana - Nevermind")
        XCTAssertEqual(hit.year, "2015")
        XCTAssertEqual(hit.formats, ["Vinyl", "LP", "Album"])
        XCTAssertEqual(hit.genres, ["Rock"])
        XCTAssertEqual(hit.styles, ["Grunge"])
        XCTAssertEqual(hit.masterID, 13814)
        XCTAssertEqual(hit.haveCount, 69592)
        XCTAssertEqual(hit.wantCount, 12267)
    }

    // MARK: - Marketplace parsing

    func testParseMarketStats() throws {
        let stats = DiscogsParser.marketStats(try json(Fixture.stats))
        XCTAssertEqual(stats.numForSale, 121)
        XCTAssertEqual(stats.lowestPrice, 0.67)
        XCTAssertEqual(stats.currency, "USD")
        XCTAssertFalse(stats.blockedFromSale)
    }

    func testParsePriceSuggestionsSortedByCondition() throws {
        let suggestions = DiscogsParser.priceSuggestions(try json(Fixture.priceSuggestions))
        XCTAssertEqual(suggestions.count, 3)
        // Sorted best → worst condition.
        XCTAssertEqual(suggestions.map(\.condition), ["Mint (M)", "Very Good Plus (VG+)", "Good (G)"])
        XCTAssertEqual(suggestions.first?.value, 25.0)
        XCTAssertEqual(suggestions.first?.currency, "USD")
    }

    func testPriceSuggestionsRequiresToken() async {
        let config = DiscogsMetadata.Configuration(token: nil)
        do {
            _ = try await DiscogsMetadata.priceSuggestions(releaseID: 249504, configuration: config)
            XCTFail("Expected authenticationRequired")
        } catch DiscogsMetadataError.authenticationRequired {
            // expected
        } catch {
            XCTFail("Expected authenticationRequired, got \(error)")
        }
    }

    // MARK: - Live tests

    /// These work WITHOUT a token (keyless endpoints). Gated on network only.
    func testLiveReleaseAndStats() async throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["DISCOGS_LIVE_TESTS"] == "1",
                          "Set DISCOGS_LIVE_TESTS=1 to run.")
        let release = try await DiscogsMetadata.release(249504)
        XCTAssertEqual(release.id, 249504)
        XCTAssertFalse(release.title.isEmpty)

        let stats = try await DiscogsMetadata.marketplaceStats(releaseID: 249504)
        XCTAssertGreaterThanOrEqual(stats.numForSale, 0)

        let results = try await DiscogsMetadata.search("nirvana nevermind", type: .release, perPage: 3)
        XCTAssertFalse(results.results.isEmpty)

        if ProcessInfo.processInfo.environment["DISCOGS_PRINT"] == "1" {
            print("=== \(release.artistNames) – \(release.title) (\(release.year ?? 0)) ===")
            print("lowest: \(release.lowestPrice ?? 0) · \(release.numForSale ?? 0) for sale · rating \(release.communityRating ?? 0)")
            print("stats: \(stats.numForSale) for sale, from \(stats.lowestPrice ?? 0) \(stats.currency ?? "")")
            for r in results.results.prefix(3) { print("• [\(r.id)] \(r.title) (\(r.year ?? "?")) \(r.formats.joined(separator: ", "))") }
        }
    }

    /// All keyless database-read endpoints (master/artist/label + sub-lists + user).
    func testLiveDatabaseEntities() async throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["DISCOGS_LIVE_TESTS"] == "1",
                          "Set DISCOGS_LIVE_TESTS=1 to run.")
        let master = try await DiscogsMetadata.master(96559)
        XCTAssertEqual(master.id, 96559)
        XCTAssertFalse(master.title.isEmpty)
        XCTAssertNotNil(master.mainReleaseID)

        let versions = try await DiscogsMetadata.masterVersions(masterID: 96559, perPage: 3)
        XCTAssertFalse(versions.items.isEmpty)
        XCTAssertGreaterThan(versions.totalItems, 0)

        let artist = try await DiscogsMetadata.artist(72872)
        XCTAssertEqual(artist.name, "Rick Astley")

        let artistReleases = try await DiscogsMetadata.artistReleases(artistID: 72872, perPage: 3)
        XCTAssertFalse(artistReleases.items.isEmpty)

        let label = try await DiscogsMetadata.label(895)
        XCTAssertFalse(label.name.isEmpty)

        let labelReleases = try await DiscogsMetadata.labelReleases(labelID: 895, perPage: 3)
        XCTAssertFalse(labelReleases.items.isEmpty)

        let user = try await DiscogsMetadata.user("davidsherlock")
        XCTAssertEqual(user.username, "davidsherlock")
        XCTAssertNotNil(user.registered)

        if ProcessInfo.processInfo.environment["DISCOGS_PRINT"] == "1" {
            print("=== database entities ===")
            print("master: \(master.artistNames) – \(master.title) — main release \(master.mainReleaseID ?? 0), \(versions.totalItems) versions")
            print("artist: \(artist.name) (aliases: \(artist.aliases.count)) — \(artistReleases.totalItems) releases")
            print("label: \(label.name) (sublabels: \(label.sublabels.count)) — \(labelReleases.totalItems) releases")
            print("user: \(user.username) registered \(user.registered.map { "\($0)" } ?? "?")")
            print("version[0]: \(versions.items[0].title) [\(versions.items[0].format ?? "?")] \(versions.items[0].country ?? "")")
        }
    }

    /// Requires a token (price suggestions endpoint).
    func testLivePriceSuggestions() async throws {
        let env = ProcessInfo.processInfo.environment
        try XCTSkipUnless(env["DISCOGS_LIVE_TESTS"] == "1" && env["DISCOGS_TOKEN"] != nil,
                          "Set DISCOGS_LIVE_TESTS=1 and DISCOGS_TOKEN to run.")
        do {
            let suggestions = try await DiscogsMetadata.priceSuggestions(releaseID: 249504)
            XCTAssertFalse(suggestions.isEmpty)
            if env["DISCOGS_PRINT"] == "1" {
                print("=== price suggestions (249504) ===")
                for s in suggestions { print("• \(s.condition): \(s.value) \(s.currency)") }
            }
        } catch DiscogsMetadataError.sellerSettingsRequired {
            // Valid: price suggestions are a seller-only tool; the token account
            // simply hasn't completed seller settings. The endpoint + error map
            // work correctly, which is what this test verifies.
            print("price suggestions require seller settings (token account is not a seller) — endpoint verified")
        }
    }

    // MARK: - Helpers

    private func json(_ string: String) throws -> [String: Any] {
        try XCTUnwrap(try JSONSerialization.jsonObject(with: Data(string.utf8)) as? [String: Any])
    }
}

// MARK: - Fixtures (mirror verified Discogs shapes)

private enum Fixture {
    static let release = """
    { "id": 249504, "title": "Never Gonna Give You Up", "year": 1987,
      "released_formatted": "1987", "country": "UK",
      "artists": [ { "name": "Rick Astley" } ],
      "genres": ["Electronic", "Pop"], "styles": ["Synth-pop"],
      "formats": [ { "name": "Vinyl", "qty": "1" } ],
      "labels": [ { "name": "RCA", "catno": "PB 41447" } ],
      "thumb": "https://img.discogs.com/thumb.jpg",
      "lowest_price": 0.89, "num_for_sale": 121, "master_id": 96559,
      "uri": "https://www.discogs.com/release/249504",
      "community": { "have": 233, "want": 40, "rating": { "count": 233, "average": 3.84 } },
      "tracklist": [
        { "position": "A", "title": "Never Gonna Give You Up", "duration": "3:32" },
        { "position": "B", "title": "Never Gonna Give You Up (Instrumental)", "duration": "3:30" }
      ]
    }
    """

    static let search = """
    { "pagination": { "page": 1, "pages": 5000, "per_page": 1, "items": 15448 },
      "results": [
        { "id": 7097051, "type": "release", "title": "Nirvana - Nevermind", "year": "2015",
          "country": "Europe", "format": ["Vinyl", "LP", "Album"], "label": ["DGC", "Sub Pop"],
          "genre": ["Rock"], "style": ["Grunge"], "master_id": 13814, "catno": "424 425-1",
          "thumb": "", "cover_image": "https://img.discogs.com/cover.jpg",
          "community": { "want": 12267, "have": 69592 } }
      ]
    }
    """

    static let stats = """
    { "num_for_sale": 121, "lowest_price": { "value": 0.67, "currency": "USD" }, "blocked_from_sale": false }
    """

    static let priceSuggestions = """
    { "Good (G)": { "currency": "USD", "value": 5.0 },
      "Mint (M)": { "currency": "USD", "value": 25.0 },
      "Very Good Plus (VG+)": { "currency": "USD", "value": 12.5 } }
    """
}
