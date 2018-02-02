//
//  RepositoryTableViewCell.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/1/18.
//  Copyright © 2018 Organization. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "RepositoryTableViewCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var scoresLabel: UILabel!
    
    // MARK: - Public Methods
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    func bind(with repository: RepositoryModel) {
        fullNameLabel.setText(repository.fullName)
        scoresLabel.text = "\(String(format: "%.2f", repository.scores))"
    }
    
}
