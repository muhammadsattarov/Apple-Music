


import UIKit

protocol SearchPresentationLogic {
  func presentData(response: Search.Model.Response.ResponseType)
}

class SearchPresenter: SearchPresentationLogic {
  weak var viewController: SearchDisplayLogic?
  
  func presentData(response: Search.Model.Response.ResponseType) {
    switch response {
    case .presentPtacks(let searchResults):
      print("Presenter .presentPtacks")
      let cells = searchResults?.results.map({ track in
        cellViewModel(from: track)
      }) ?? []

      let searchViewModel = SearchViewModel.init(cells: cells)

      viewController?.displayData(viewModel: .displayTracks(searchViewModel))
    case .presentFooterView:
      viewController?.displayData(viewModel: .displayFooterView)
    }
  }
}


private extension SearchPresenter {
  func cellViewModel(from track: Track) -> SearchViewModel.Cell {
    return SearchViewModel.Cell(
      iconUrlString: track.artworkUrl100,
      trackName: track.trackName,
      artistName: track.artistName,
      collectionName: track.collectionName ?? "",
      previewUrl: track.previewUrl
    )
  }
}

