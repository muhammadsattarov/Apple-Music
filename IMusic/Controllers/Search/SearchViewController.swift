


import UIKit

protocol SearchDisplayLogic: AnyObject {
  func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

class SearchViewController: UIViewController, SearchDisplayLogic {

  var interactor: SearchBusinessLogic?
  var router: (NSObjectProtocol & SearchRoutingLogic)?


  @IBOutlet weak var tableView: UITableView!
  private let searchController = UISearchController(searchResultsController: nil)
  private var searchViewModel = SearchViewModel(cells: [])
  private var timer: Timer?

  private lazy var footerView = FooterView()

  weak var tabbarDelegate: MainTabBarControllerDelegate?

  // MARK: Object lifecycle
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: Setup
  
  private func setup() {
    print(#function)

    let viewController        = self
    let interactor            = SearchInteractor()
    let presenter             = SearchPresenter()
    let router                = SearchRouter()
    viewController.interactor = interactor
    viewController.router     = router
    interactor.presenter      = presenter
    presenter.viewController  = viewController
    router.viewController     = viewController
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupTableView()
    setupSearchBar()

    self.interactor?.makeRequest(request: .getTracks("Konsta"))
  }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            let tabbarVC = keyWindow.rootViewController as? MainTabBarController
            tabbarVC?.trackDetailView.delegate = self
        }
    }
    
  func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
    switch viewModel {
    case .displayTracks(let searchViewModel):
      DispatchQueue.main.async {
        self.searchViewModel = searchViewModel
        self.tableView.reloadData()
        self.footerView.hideIndicator()
      }
    case .displayFooterView:
      footerView.showIndicator()
    }
  }
}

// MARK: - Add Subviews
private extension SearchViewController {
  func setupSearchBar() {
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    navigationItem.searchController?.searchBar.delegate = self
  }
}

// MARK: - Add Subviews
private extension SearchViewController {
  func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: SearchTableViewCell.reuseId)
    tableView.tableFooterView = footerView
    tableView.backgroundColor = .clear
  }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchViewModel.cells.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseId, for: indexPath) as! SearchTableViewCell

    let cellViewModel = searchViewModel.cells[indexPath.row]
    cell.configure(with: cellViewModel)
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 84
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let model = searchViewModel.cells[indexPath.row]
    self.tabbarDelegate?.maximizingTrackDetailContorller(viewModel: model)
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.text = "Please, enter search term above..."
    label.font = .systemFont(ofSize: 18, weight: .semibold)
    label.textColor = .black
    label.textAlignment = .center
    return label
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return searchViewModel.cells.count > 0 ? 0 : 250
  }
}

extension SearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
      self?.interactor?.makeRequest(request: .getTracks(searchText))
    })
  }
}

extension SearchViewController: TrackMovingDelegate {
  func getTrack(isForwardTrack: Bool) -> SearchViewModel.Cell? {
    guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
    tableView.deselectRow(at: indexPath, animated: true)
    var nextIndexPath: IndexPath!
    if isForwardTrack {
      nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
      if nextIndexPath.row == searchViewModel.cells.count {
        nextIndexPath.row = 0
      }
    } else {
      nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
      if nextIndexPath.row == -1 {
        nextIndexPath.row = searchViewModel.cells.count - 1
      }
    }

    tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
    let cellViewModel = searchViewModel.cells[indexPath.row]
    print("CellViewModel trackName: \(cellViewModel.trackName)")
    return cellViewModel
  }

  func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
    return getTrack(isForwardTrack: false)
  }
  
  func moveForwardForPreviousTrack() -> SearchViewModel.Cell? {
    return getTrack(isForwardTrack: true)
  }
  

}
