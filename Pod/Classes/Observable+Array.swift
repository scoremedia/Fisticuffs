//
//  Observable+Array.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import Foundation


public enum ArrayChange<T> {
    case Set(elements: [T])
    case Insert(index: Int, newElements: [T])
    case Remove(range: Range<Int>, removedElements: [T])
    case Replace(range: Range<Int>, removedElements: [T], newElements: [T])
}


public extension Observable where T: CollectionType, T.Generator.Element : Equatable {
    func subscribeArray(options: SubscriptionOptions = SubscriptionOptions(), callback: (T, ArrayChange<T.Generator.Element>) -> Void) -> Disposable {
        return subscribeDiff(options) { oldValue, newValue in
            let change = calculateChange(oldValue, newValue) { a, b in a == b }
            callback(newValue, change)
        }
    }
}

public extension Observable where T: CollectionType, T.Generator.Element : AnyObject {
    func subscribeArray(options: SubscriptionOptions = SubscriptionOptions(), callback: (T, ArrayChange<T.Generator.Element>) -> Void) -> Disposable {
        return subscribeDiff(options) { oldValue, newValue in
            let change = calculateChange(oldValue, newValue) { a, b in a === b }
            callback(newValue, change)
        }
    }
}

private func calculateChange<T: CollectionType>(a: T, _ b: T, compare: (T.Generator.Element, T.Generator.Element) -> Bool) -> ArrayChange<T.Generator.Element> {
    var genA = a.generate()
    var genB = b.generate()
    
    var objA = genA.next()
    var objB = genB.next()
    
    // "seek" to first change
    while let objA_ = objA, objB_ = objB where compare(objA_, objB_) {
        objA = genA.next()
        objB = genB.next()
    }
    
    if objA == nil && objB == nil {
        
    }
    
    switch (objA, objB) {
    case (nil, nil):
        // reached the end of both sequences, no changes detected
        return ArrayChange.Set(elements: Array(a))
        
    case let (objA, nil):
        // removed items
        break //TODO: Implement
        
    case let (nil, objB):
        // appended items
        break //TODO: Implement
        
    default:
        break
    }
    
    return ArrayChange.Set(elements: Array(a))
}
