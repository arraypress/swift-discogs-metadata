# Swift Discogs Metadata

A Swift library for fetching music release metadata, searching the Discogs database, and reading marketplace prices for records, CDs, and cassettes.

Most of it works **without any credentials**. A free personal token adds per-condition price suggestions and a higher rate limit.

## Features

- 💿 **Release metadata** — title, artists, year, genres/styles, formats, labels, country, tracklist
- 💰 **Marketplace prices** — `lowestPrice` + `numForSale` inline on releases, plus a dedicated `marketplaceStats(...)` (and token-gated per-condition `priceSuggestions(...)`)
- 🔎 **Database search** — releases, masters, artists, labels; filter by genre/style/year/format/country; paginated
- 🗂️ **Full read surface** — releases, masters (+ versions), artists (+ discography), labels (+ catalog), and public user profiles
- 🔓 **Mostly keyless** — release/search/stats need no token (25 req/min); a free personal token raises it to 60/min and unlocks price suggestions
- 🍎 **Cross-platform** — macOS, iOS, tvOS, watchOS · Swift 6 · async/await
- 🛡️ **Typed error handling**

## Authentication

- **No token:** release lookup, search, and marketplace stats all work as-is.
- **Personal access token** (free): generate at `https://www.discogs.com/settings/developers`, then pass it as `Configuration(token:)` or set `DISCOGS_TOKEN`. Enables `priceSuggestions(...)` and 60 req/min.

Discogs requires a descriptive `User-Agent`; a default is provided and can be overridden in `Configuration`.

## Usage

```swift
import DiscogsMetadata

// Release + inline marketplace price
let release = try await DiscogsMetadata.release(249504)
print("\(release.artistNames) – \(release.title) (\(release.year ?? 0))")
if let low = release.lowestPrice {
    print("from \(low) · \(release.numForSale ?? 0) for sale · ★\(release.communityRating ?? 0)")
}

// Search
let results = try await DiscogsMetadata.search("nirvana nevermind", type: .release, perPage: 25)
for hit in results.results {
    print("[\(hit.id)] \(hit.title) (\(hit.year ?? "?")) — \(hit.formats.joined(separator: ", "))")
}

// Marketplace stats in a chosen currency
let stats = try await DiscogsMetadata.marketplaceStats(releaseID: 249504, currency: "GBP")
print("\(stats.numForSale) for sale from \(stats.lowestPrice ?? 0) \(stats.currency ?? "")")

// Browse the database: masters, artists, labels, users (all keyless)
let master = try await DiscogsMetadata.master(96559)
let versions = try await DiscogsMetadata.masterVersions(masterID: 96559)      // every pressing
let artist = try await DiscogsMetadata.artist(72872)
let discography = try await DiscogsMetadata.artistReleases(artistID: 72872)     // paginated
let label = try await DiscogsMetadata.label(895)
let catalog = try await DiscogsMetadata.labelReleases(labelID: 895)             // paginated
let user = try await DiscogsMetadata.user("davidsherlock")

// Per-condition price suggestions (requires a token AND seller settings)
let config = DiscogsMetadata.Configuration(token: "…")
let suggestions = try await DiscogsMetadata.priceSuggestions(releaseID: 249504, configuration: config)
for s in suggestions { print("\(s.condition): \(s.value) \(s.currency)") }  // sorted best → worst
```

> **Price suggestions are a seller tool.** Discogs only returns them to accounts
> that have completed their seller settings; other accounts get
> `DiscogsMetadataError.sellerSettingsRequired`. Everything else — release lookup,
> search, and marketplace stats (including the lowest current price) — works with
> just a token (or no token at all).

## Models

| Type | Description |
|------|-------------|
| `DiscogsRelease` | `id`, `title`, `artists`, `year`, `released`, `genres`, `styles`, `formats`, `labels`, `country`, `tracklist`, `thumbnailURL`, `lowestPrice`, `numForSale`, `communityRating`, `haveCount`, `wantCount`, `masterID`, `uri` |
| `DiscogsSearchResults` / `DiscogsSearchResult` | Paginated hits with `id`, `type`, `title`, `year`, `formats`, `labels`, `genres`, `styles`, `masterID`, `catalogNumber`, images, have/want |
| `DiscogsMarketStats` | `numForSale`, `lowestPrice`, `currency`, `blockedFromSale` |
| `DiscogsPriceSuggestion` | `condition`, `value`, `currency` |
| `DiscogsMaster` | `id`, `title`, `year`, `artists`, `genres`, `styles`, `mainReleaseID`, `tracklist`, `lowestPrice`, `numForSale`, `imageURL`, `uri` |
| `DiscogsArtist` | `id`, `name`, `realName`, `profile`, `aliases`, `members`, `groups`, `nameVariations`, `urls`, `imageURL`, `uri` |
| `DiscogsLabel` | `id`, `name`, `profile`, `contactInfo`, `parentLabel`, `sublabels`, `urls`, `imageURL`, `uri` |
| `DiscogsUser` | `id`, `username`, `name`, `profile`, `location`, `registered`, `rank`, `numForSale`, seller/buyer ratings, `avatarURL`, `uri` |
| `DiscogsReleaseSummary` / `DiscogsPagedResults<T>` | Version/discography entries + pagination (`page`, `pages`, `totalItems`, `hasNextPage`) |
| `DiscogsMetadataError` | Typed errors with `errorDescription` |

## Testing

```bash
swift test                                          # offline unit tests (fixtures)
DISCOGS_LIVE_TESTS=1 swift test                     # + keyless live tests (release/search/stats)
DISCOGS_LIVE_TESTS=1 DISCOGS_TOKEN=… swift test     # + token-gated price suggestions
```

## License

MIT

## Author

David Sherlock
