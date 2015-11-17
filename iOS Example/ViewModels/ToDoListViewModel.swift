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
    let promptToAddNewItem = Event<Void>()
    
    func tappedAddNewItem() {
        promptToAddNewItem.fire()
    }
    
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        self.items = dataManager.toDoItems
    }
}
