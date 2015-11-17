//
//  AddItemViewModel.swift
//  iOS Example
//
//  Created by Darren Clark on 2015-11-17.
//  Copyright © 2015 theScore. All rights reserved.
//


import SwiftMVVMBinding


enum AddItemResult {
    case NewToDoItem(ToDoItem)
    case Cancelled
}



class AddItemViewModel {
    
    let item = ToDoItem()
    let finished = Event<AddItemResult>()
    
    lazy var inputIsValid: Computed<Bool> = Computed { [item = self.item] in
        return item.title.value.isEmpty == false
    }
    
    func doneTapped() {
        if !inputIsValid.value {
            return
        }
        
        finished.fire(.NewToDoItem(item))
    }
    
    func cancelTapped() {
        finished.fire(.Cancelled)
    }
    
}
