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


public extension Observable where T: CollectionType {
    private typealias Element = T.Generator.Element
    
    
    func subscribeArray(options: SubscriptionOptions, callback: (T, ArrayChange<Element>) -> Void) -> Disposable {
        return subscribe(options) { newValue in
            let change = calculateChange(newValue, b: newValue)
            callback(newValue, change)
        }
    }
    
    func subscribeArray(callback: (T, ArrayChange<Element>) -> Void) -> Disposable {
        return subscribe { newValue in
            let change = calculateChange(newValue, b: newValue)
            callback(newValue, change)
        }
    }
}


private func calculateChange<T: CollectionType>(a: T, b: T) -> ArrayChange<T.Generator.Element> {
    return ArrayChange.Set(elements: Array(a))
}
