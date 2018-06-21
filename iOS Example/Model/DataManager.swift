//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Fisticuffs


class DataManager {
    
    static let defaultPath: String = {
        let documentsDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        return documentsDirectory.appendingPathComponent("todos.plist")
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
            serializedRepresentation = Computed { [items = self.toDoItems] in DataManager.modelsToPlist(toDos: items.value) }
            
            let opts = SubscriptionOptions(notifyOnSubscription: false, when: .afterChange)
            _ = serializedRepresentation!.subscribe(opts) { [weak self] in
                self?.save(filePath: filePath)
            }
        }
    }
}

//MARK: - Load/Save
extension DataManager {
    
    func load(filePath: String) -> [ToDoItem] {
        guard let plist = NSArray(contentsOfFile: filePath) else {
            return []
        }
        return DataManager.plistToModels(plist: plist)
    }
    
    func save(filePath: String) {
        let plist = DataManager.modelsToPlist(toDos: toDoItems.value)
        plist.write(toFile: filePath, atomically: true)
    }
    
}

//MARK: - Serialization
extension DataManager {
    static func plistToModels(plist: NSArray) -> [ToDoItem] {
        do {
            let items = try (plist as [AnyObject]).map { object -> ToDoItem in
                guard let dict = object as? NSDictionary,
                    let title = dict["title"] as? String,
                    let completed = dict["completed"] as? Bool else {
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
