//
//  ToDoListViewController.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-10-15.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import UIKit
import SwiftMVVMBinding


class ToDoListViewController : UIViewController {
    
    let viewModel = ToDoListViewModel()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(ToDoItemCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.b_configure(viewModel.toDoItems) { config in
            config.usingCellIdentifier("Cell") { item, cell in
                (cell as! ToDoItemCell).bind(item)
            }
            
            config.onSelect(viewModel.markToDoCompleted)
            
            config.allowsDeletion = true
            config.allowsReordering = true
        }
        tableView.b_editing = viewModel.editing
        
        addButton.b_onTap(viewModel.addToDo)
        
        editingButton.b_onTap(viewModel.toggleEditing)
        editingButton.b_title = viewModel.toggleEditingButtonTitle
        
        
        viewModel.editItem = { [weak self] item in
            let alert = UIAlertController(title: "To Do", message: nil, preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler { textField in
                textField.placeholder = "Title"
                textField.b_text = item.title
            }
            
            let doneButton = UIAlertAction(title: "Done", style: .Default, handler: nil)
            alert.addAction(doneButton)
            
            self?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
