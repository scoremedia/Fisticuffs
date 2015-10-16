//
//  SearchResultCell.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-10-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    func bind(viewModel: SearchResultViewModel) {
        emojiLabel.text = viewModel.emoji
        nameLabel.text = viewModel.name
    }
    
}
