//
//  DataManager.swift
//  iOS Example
//
//  Created by Darren Clark on 2015-11-17.
//  Copyright © 2015 theScore. All rights reserved.
//

import SwiftMVVMBinding


class DataManager {
    
    static let sharedManager = DataManager()
    
    let toDoItems = Observable<[ToDoItem]>([])
    
}
