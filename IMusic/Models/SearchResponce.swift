

import Foundation

struct SearchResponse: Codable {
  let resultCount: Int
  let results: [Track]
}

struct Track: Codable {
  let artistName: String
  let collectionName: String?
  let trackName: String
  let artworkUrl100: String
  let previewUrl: String?
}
