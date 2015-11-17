//
//  ToDoItemCell.swift
//  iOS Example
//
//  Created by Darren Clark on 2015-11-17.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit
import SwiftMVVMBinding


class ToDoItemCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    
    func bind(item: ToDoItem) {
        title.b_text <-- item.title
        
        b_accessoryType.bind(item.completed, transform: { completed in completed ? .Checkmark : .None })
    }
    
}
