


import UIKit

protocol SearchBusinessLogic {
  func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {

  var presenter: SearchPresentationLogic?
  var service: SearchService?
  
  func makeRequest(request: Search.Model.Request.RequestType) {
    if service == nil {
      service = SearchService()
    }

    switch request {
    case .getTracks(let searchText):
      print("Interactor .getTracks")
      presenter?.presentData(response: .presentFooterView)
      service?.fetchTracks(searchText, completion: { [weak self] tracks in
        self?.presenter?.presentData(response: .presentPtacks(tracks))
      })
    }
  }
  
}
