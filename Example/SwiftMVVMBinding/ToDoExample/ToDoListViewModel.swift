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
    
    var toDoItems = ObservableArray<ToDoItemViewModel>([
        ToDoItemViewModel(title: "First task"),
        ToDoItemViewModel(title: "Another task"),
        ToDoItemViewModel(title: "One final task")
    ])
    
    let editing = Observable(false)
    
    lazy var toggleEditingButtonTitle: Computed<String> = Computed {
        return self.editing.value ? "Done" : "Edit"
    }
    
    func addToDo() {
        let todo = ToDoItemViewModel()
        todo.title.value = "Hello"
        toDoItems.append(todo)
    }
    
    func toggleEditing() {
        editing.value = !editing.value
    }
    
    func markToDoCompleted(item: ToDoItemViewModel) {
        item.completed.value = !item.completed.value
    }
    
}
