//
//  ViewController.swift
//  iOS Example
//
//  Created by Darren Clark on 2015-11-17.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit
import SwiftMVVMBinding


class ToDoListViewController: UIViewController {

    let viewModel = ToDoListViewModel(dataManager: DataManager.sharedManager)
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.b_onTap += viewModel.tappedAddNewItem
        
        editButton.b_title <-- viewModel.editButtonTitle
        editButton.b_onTap += viewModel.tappedEditButton
        
        viewModel.promptToAddNewItem += showAddItemController
        
        tableView.b_configure(viewModel.items) { config in
//TODO: Re-add this functionality
//            config.allowsDeletion = true
//            config.allowsReordering = true
            
            config.allowsMoving = true
            config.useCell(reuseIdentifier: "Cell") { item, cell in
                (cell as! ToDoItemCell).bind(item)
            }
            config.onSelect += { _, item in
                item.completed.value = !item.completed.value
            }
        }
        tableView.b_editing <-- viewModel.editing
    }
    
    
    func showAddItemController() {
        performSegueWithIdentifier("AddItem", sender: nil)
    }
}

