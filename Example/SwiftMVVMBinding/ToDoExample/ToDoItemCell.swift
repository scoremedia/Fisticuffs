//
//  ToDoItemCell.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-10-15.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import UIKit

class ToDoItemCell: UITableViewCell {
    
    func bind(viewModel: ToDoItemViewModel) {
        textLabel?.b_text.bind(viewModel.title)
        b_accessoryType = viewModel.completed.map { value in
            value ? UITableViewCellAccessoryType.Checkmark : .None
        }
    }
    
}
