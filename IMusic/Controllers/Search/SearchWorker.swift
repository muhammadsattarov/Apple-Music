


import UIKit

class SearchService {
  let networkService = NetworkService()

  func fetchTracks(_ searchText: String, completion: @escaping (SearchResponse?) -> Void) {
    networkService.fetchTracks(searchText, completion: completion)
  }
}
