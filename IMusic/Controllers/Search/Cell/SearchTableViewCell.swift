


import UIKit

protocol SearchViewModelProtocol {
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
    var iconUrlString: String? { get }
}



class SearchTableViewCell: UITableViewCell {
    static let reuseId = "SearchTableViewCell"
    
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var cell: SearchViewModel.Cell?
    
    func configure(with model: SearchViewModel.Cell) {
        self.cell = model
        
        let savedTracks = UserDefaults.standard.savedTracks()
        let hasFavorite = savedTracks.firstIndex(where: {
            $0.trackName == self.cell?.trackName && $0.artistName == self.cell?.artistName
        }) != nil
        
        addButton.isHidden = hasFavorite ? true : false
        
        trackNameLabel.text = model.trackName
        artistNameLabel.text = model.artistName
        collectionNameLabel.text = model.collectionName
        guard let iconUrl = model.iconUrlString else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.trackImage.sd_setImage(with: URL(string: iconUrl))
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImage.image = nil
    }
    
    @IBAction func addTrackButton(_ sender: Any) {
        print(#function)
        let defaults = UserDefaults.standard
        guard let cell = cell else { return }
        
        addButton.isHidden = true
        
        var listOfTracks = defaults.savedTracks()
        
        listOfTracks.append(cell)
        
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: listOfTracks, requiringSecureCoding: false) {
            defaults.set(savedData, forKey: UserDefaults.favoriteTracksKey)
        }
    }
    
}
