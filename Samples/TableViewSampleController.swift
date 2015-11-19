//
//  TableViewSampleController.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-18.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit
import SwiftMVVMBinding

class TableViewSampleViewModel {
    let items = Observable([1, 2, 3, 4, 5, 6, 7, 8, 9])
    
    let editing = Observable(false)
    lazy var editingButtonTitle: Computed<String> = Computed { [editing = self.editing] in
        editing.value ? "Done" : "Edit"
    }
    
    func toggleEditing() {
        editing.value = !editing.value
    }
    
    
    func prependItem() {
        if let min = items.value.minElement() {
            items.value.insert(min - 1, atIndex: 0)
        }
        else {
            items.value.insert(1, atIndex: 0)
        }
    }
    
    func appendItem() {
        if let max = items.value.maxElement() {
            items.value.append(max + 1)
        }
        else {
            items.value.append(1)
        }
    }
}


class TableViewSampleController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var prependButton: UIBarButtonItem!
    @IBOutlet var appendButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    
    //MARK: -
    
    let viewModel = TableViewSampleViewModel()
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.b_configure(viewModel.items) { config in
            config.allowsMoving = true
            config.allowsDeletion = true
            config.useCell(reuseIdentifier: "Cell") { item, cell in
                cell.textLabel?.text = "\(item)"
            }
        }
        tableView.b_editing <-- viewModel.editing
        
        editButton.b_onTap += viewModel.toggleEditing
        editButton.b_title <-- viewModel.editingButtonTitle
        
        prependButton.b_onTap += viewModel.prependItem
        appendButton.b_onTap += viewModel.appendItem
    }
    
}
