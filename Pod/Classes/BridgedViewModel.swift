//
//  BridgedViewModel.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

public class BridgedViewModel: NSObject {
    
    private var registeredKVOPaths = Set<String>()
    
    private func startGeneratingKVONotifications(keyPath: String) {
        guard !registeredKVOPaths.contains(keyPath) else {
            return
        }
        
        let mirror = Mirror(reflecting: self)
        let propertyIndex = mirror.children.indexOf { $0.label == keyPath }
        
        if let propertyIndex = propertyIndex {
            let child = mirror.children[propertyIndex]
            if let value = child.value as? _Observable {
                value.observeWillChange {
                    self.willChangeValueForKey(keyPath)
                }
                value.observeDidChange {
                    self.didChangeValueForKey(keyPath)
                }

                registeredKVOPaths.insert(keyPath)
            }
        }
    }
    
    public override func addObserver(observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutablePointer<Void>) {
        startGeneratingKVONotifications(keyPath)
        super.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
    }
    
    public override func valueForUndefinedKey(key: String) -> AnyObject? {
        let mirror = Mirror(reflecting: self)
        let propertyIndex = mirror.children.indexOf { $0.label == key }
        
        if let propertyIndex = propertyIndex {
            let child = mirror.children[propertyIndex]
            if let value = child.value as? _Observable {
                return value.untypedValue
            }
        }
        
        return super.valueForUndefinedKey(key)
    }
    
}

extension Observable : _Observable {
    public var untypedValue: AnyObject? {
        if let value = value as? AnyObject {
            return value
        }
        return nil
    }
    
    func observeWillChange(callback: Void -> Void) {
        willChange.append { (value: T) -> Void in
            callback()
        }
    }

    func observeDidChange(callback: Void -> Void) {
        didChange.append { (value: T) -> Void in
            callback()
        }
    }
}

protocol _Observable {
    var untypedValue: AnyObject? { get }
    
    func observeWillChange(callback: Void -> Void)
    func observeDidChange(callback: Void -> Void)
}

