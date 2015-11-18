//
//  ToDoListViewModel.swift
//  iOS Example
//
//  Created by Darren Clark on 2015-11-17.
//  Copyright © 2015 theScore. All rights reserved.
//

import SwiftMVVMBinding


class ToDoListViewModel {
    
    private let dataManager: DataManager
    
    let items: Observable<[ToDoItem]>
    
    //MARK: -
    let promptToAddNewItem = Event<Void>()
    
    func tappedAddNewItem() {
        promptToAddNewItem.fire()
    }
    
    //MARK: -
    let editing = Observable(false)
    lazy var editButtonTitle: Computed<String> = Computed { [editing = self.editing] in
        editing.value ? "Done" : "Edit"
    }
    
    func tappedEditButton() {
        editing.value = !editing.value
    }
    
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        self.items = dataManager.toDoItems
    }
}
