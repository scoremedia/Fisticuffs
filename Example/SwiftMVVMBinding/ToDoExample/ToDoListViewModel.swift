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
    
    func addToDo() {
        toDoItems.append("item")
    }
    
}
