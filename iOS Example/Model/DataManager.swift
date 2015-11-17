//
//  DataManager.swift
//  iOS Example
//
//  Created by Darren Clark on 2015-11-17.
//  Copyright © 2015 theScore. All rights reserved.
//

import SwiftMVVMBinding


class DataManager {
    
    static let defaultPath: String = {
        let documentsDirectory: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        return documentsDirectory.stringByAppendingPathComponent("todos.plist")
    }()
    
    static let sharedManager = DataManager(filePath: defaultPath)
    
    
    let toDoItems = Observable<[ToDoItem]>([])
    
    var serializedRepresentation: Computed<NSArray>? = nil
    
    /**
     Initializes a new instance.  If a `file` is provided, to do items will be saved there
     
     - parameter filePath: Save file path
     */
    init(filePath: String?) {
        if let filePath = filePath {
            toDoItems.value = load(filePath: filePath)
            
            // We observe the results of DataManager.modelsToPlist so that we catch changes to both
            // the list of to do items & each property on them (as they are accessed in serialization)
            serializedRepresentation = Computed { [items = self.toDoItems] in DataManager.modelsToPlist(items.value) }
            
            let opts = SubscriptionOptions(notifyOnSubscription: false, when: .AfterChange)
            serializedRepresentation!.subscribe(opts) { [weak self] in
                self?.save(filePath: filePath)
            }
        }
    }
}

//MARK: - Load/Save
extension DataManager {
    
    func load(filePath filePath: String) -> [ToDoItem] {
        guard let plist = NSArray(contentsOfFile: filePath) else {
            return []
        }
        return DataManager.plistToModels(plist)
    }
    
    func save(filePath filePath: String) {
        let plist = DataManager.modelsToPlist(toDoItems.value)
        plist.writeToFile(filePath, atomically: true)
    }
    
}

//MARK: - Serialization
extension DataManager {
    static func plistToModels(plist: NSArray) -> [ToDoItem] {
        do {
            let items = try (plist as [AnyObject]).map { object -> ToDoItem in
                guard let dict = object as? NSDictionary,
                    title = dict["title"] as? String,
                    completed = dict["completed"] as? Bool else {
                        throw NSError(domain: "DataManagerParseError", code: 0, userInfo: nil)
                }
                
                let toDoItem = ToDoItem()
                toDoItem.title.value = title
                toDoItem.completed.value = completed
                return toDoItem
            }
            
            return items
        }
        catch {
            return []
        }
    }
    
    static func modelsToPlist(toDos: [ToDoItem]) -> NSArray {
        return toDos.map { toDo in
            return [
                "title": toDo.title.value,
                "completed": toDo.completed.value
            ] as [String: AnyObject]
        } as NSArray
    }
}
