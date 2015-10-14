//
//  NSObject+AssociatedObjects.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

private var keys = [String:NSObject]()

extension NSObject {
    
    func findKey(name: String, type: Any) -> UnsafePointer<Void> {
        let keyString = "\(name)__\(type)"
        if let keyObj = keys[keyString] {
            return UnsafePointer(Unmanaged.passUnretained(keyObj).toOpaque())
        }
        else {
            let keyObj = NSObject()
            keys[keyString] = keyObj
            return UnsafePointer(Unmanaged.passUnretained(keyObj).toOpaque())
        }
    }
    
    func get<T: AnyObject>(name: String) -> T? {
        let key = findKey(name, type: T.self)
        return objc_getAssociatedObject(self, key) as? T
    }
    
    func get<T: AnyObject>(name: String, orSet block: (Void) -> T) -> T {
        if let existing: T = get(name) {
            return existing
        }
        else {
            let new = block()
            set(name, value: new)
            return new
        }
    }
    
    func set<T: AnyObject>(name: String, value: T?) {
        let key = findKey(name, type: T.self)
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
    
}
