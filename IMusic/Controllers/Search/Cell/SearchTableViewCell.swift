//
//  SearchTableViewCell.swift
//  IMusic
//
//  Created by user on 16/03/25.
//

import UIKit

protocol SearchViewModelProtocol {
  
}

class SearchTableViewCell: UITableViewCell {

  @IBOutlet weak var trackImage: UIImageView!
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var collectionNameLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()

    }

  func configure(with model: SearchViewModelProtocol) {
    
  }
}
