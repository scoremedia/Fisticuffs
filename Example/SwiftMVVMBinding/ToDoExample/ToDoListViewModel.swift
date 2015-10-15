//
//  ToDoListViewModel.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-10-15.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import SwiftMVVMBinding


class ToDoListViewModel {
    
    var editItem: ((ToDoItemViewModel) -> Void)?
    
    
    var toDoItems = ObservableArray<ToDoItemViewModel>([])
    
    let editing = Observable(false)
    
    lazy var toggleEditingButtonTitle: Computed<String> = Computed {
        return self.editing.value ? "Done" : "Edit"
    }
    
    func addToDo() {
        let todo = ToDoItemViewModel()
        toDoItems.append(todo)
        
        editItem?(todo)
    }
    
    func toggleEditing() {
        editing.value = !editing.value
    }
    
    func markToDoCompleted(item: ToDoItemViewModel) {
        item.completed.value = !item.completed.value
    }
    
}
