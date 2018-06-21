//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Fisticuffs


class ToDoListViewController: UIViewController {

    let viewModel = ToDoListViewModel(dataManager: DataManager.sharedManager)
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = addButton.b_onTap.subscribe(viewModel.tappedAddNewItem)
        
        editButton.b_title.bind(viewModel.editButtonTitle)
        _ = editButton.b_onTap.subscribe(viewModel.tappedEditButton)
        
        _ = viewModel.promptToAddNewItem.subscribe(showAddItemController)
        
        tableView.b_configure(viewModel.items) { config in
//TODO: Re-add this functionality
//            config.allowsDeletion = true
//            config.allowsReordering = true
            
            config.allowsMoving = true
            config.useCell(reuseIdentifier: "Cell") { item, cell in
                (cell as! ToDoItemCell).bind(item: item)
            }
            _ = config.onSelect.subscribe { _, item in
                item.completed.value = !item.completed.value
            }
        }
        tableView.b_editing.bind(viewModel.editing)
    }
    
    
    func showAddItemController() {
        performSegue(withIdentifier: "AddItem", sender: nil)
    }
}

