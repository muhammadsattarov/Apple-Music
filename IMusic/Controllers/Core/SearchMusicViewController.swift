


import UIKit
import Alamofire
import SDWebImage

class SearchMusicViewController: UIViewController {

  private let tableView: UITableView = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.register(UITableViewCell.self,
                forCellReuseIdentifier: "cell")
    return $0
  }(UITableView())

  private let searchController = UISearchController(searchResultsController: nil)
  private var timer: Timer?

  private var tracks: [ Track] = []

  // MARK: - Override Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
}

// MARK: - Setup Views
private extension SearchMusicViewController {
  func setupViews() {
    view.backgroundColor = .white
    navigationItem.title = "Search"
    navigationController?.navigationBar.prefersLargeTitles = true
    addSubviews()
    setupSearchBar()
    setConstraints()
  }
}

// MARK: - Add Subviews
private extension SearchMusicViewController {
  func setupSearchBar() {
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    navigationItem.searchController?.searchBar.delegate = self
  }
}

// MARK: - Add Subviews
private extension SearchMusicViewController {
  func addSubviews() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }
}

// MARK: - Constraints
private extension SearchMusicViewController {
  func setConstraints() {
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

extension SearchMusicViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let track = tracks[indexPath.row]

    cell.textLabel?.text = "\(track.artistName) \n\(track.trackName)"
    cell.textLabel?.numberOfLines = 2
    DispatchQueue.main.async {
      cell.imageView?.sd_setImage(with: URL(string: track.artworkUrl100))
    }
    return cell
  }
}

extension SearchMusicViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in

      let url = "https://itunes.apple.com/search"
      let params = ["term":"\(searchText)", "limit":"10"]

      AF.request(url,method: .get, parameters: params, headers: nil).response { [weak self] response in
        guard let self = self else { return }
        if let error = response.error {
          print("AF error is:", error.localizedDescription)
        }
        guard let data = response.data else { return }
        let decoder = JSONDecoder()

        do {
          let artists = try decoder.decode(SearchResponse.self, from: data)
          DispatchQueue.main.async {
            self.tracks = artists.results
            self.tableView.reloadData()
          }
        } catch {
          print("Decode error is:", error.localizedDescription)
        }
      }
    })
  }
}


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
