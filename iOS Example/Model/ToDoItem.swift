//
//  ToDoItem.swift
//  iOS Example
//
//  Created by Darren Clark on 2015-11-17.
//  Copyright © 2015 theScore. All rights reserved.
//

import SwiftMVVMBinding

class ToDoItem: ViewModel {
    
    let title = Observable("")
    let completed = Observable(false)
    
}


