//
//  NetworkService.swift
//  IMusic
//
//  Created by user on 16/03/25.
//

import Foundation
import Alamofire

class NetworkService {

  func fetchTracks(_ searchText: String,
                   completion: @escaping (SearchResponse?) -> Void) {
    let url = "https://itunes.apple.com/search"
    let params = ["term":"\(searchText)", "limit":"10"]

    AF.request(url,method: .get, parameters: params, headers: nil).response { [weak self] response in
      guard let self = self else { return }
      if let error = response.error {
        completion(nil)
        print("AF error is:", error.localizedDescription)
      }
      guard let data = response.data else { return }
      let decoder = JSONDecoder()

      do {
        let artists = try decoder.decode(SearchResponse.self, from: data)
        completion(artists)
      } catch {
        completion(nil)
        print("Decode error is:", error.localizedDescription)
      }
    }
  }
}
