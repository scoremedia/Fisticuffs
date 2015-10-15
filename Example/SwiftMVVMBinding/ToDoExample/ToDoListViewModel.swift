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
    
    var toDoItems = ObservableArray(["one", "two", "three"])
    
    let editing = Observable(false)
    
    lazy var toggleEditingButtonTitle: Computed<String> = Computed {
        return self.editing.value ? "Done" : "Edit"
    }
    
    func addToDo() {
        toDoItems.append("item")
    }
    
    func toggleEditing() {
        editing.value = !editing.value
    }
    
    func markToDoCompleted(item: String) {
        while let index = toDoItems.indexOf(item) {
            toDoItems.removeAtIndex(index)
        }
    }
    
}
