//
//  AddItemViewController.swift
//  iOS Example
//
//  Created by Darren Clark on 2015-11-17.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit
import SwiftMVVMBinding


class AddItemViewController: UITableViewController {
    
    let viewModel = AddItemViewModel()
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var titleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.b_onTap += viewModel.doneTapped
        cancelButton.b_onTap += viewModel.cancelTapped
        titleField.b_text <-> viewModel.item.title
        
        viewModel.finished += { [weak self] _, result in
            switch result {
            case let .NewToDoItem(item):
                DataManager.sharedManager.toDoItems.value.append(item)
                break
                
            default:
                break
            }
            
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        titleField.becomeFirstResponder()
    }
}


