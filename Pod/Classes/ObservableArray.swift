//
//  ObservableArray.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import Foundation

public enum ArrayChange<T> {
    case Initial(elements: [T])
    case Insert(index: Int, newElements: [T])
    case Remove(range: Range<Int>, removedElements: [T])
    case Replace(range: Range<Int>, removedElements: [T], newElements: [T])
}


public class ObservableArray<T> : Observable<[T]> {
    
    public typealias ArrayChangeCallback = ([T], ArrayChange<T>) -> Void
    
    private var subscriptions = [ArraySubscription<T>]()
    
    public required init() {
        super.init([])
    }
    
    override init(_ initial: [T]) {
        super.init(initial)
    }
    
}

extension ObservableArray {
    
    @warn_unused_result(message="Returned Disposable must be used to cancel the subscription")
    public func subscribeArray(callback: ArrayChangeCallback) -> Disposable {
        return subscribeArray(SubscriptionOptions(), callback: callback)
    }
    
    @warn_unused_result(message="Returned Disposable must be used to cancel the subscription")
    public func subscribeArray(options: SubscriptionOptions, callback: ArrayChangeCallback) -> Disposable {
        let subscription = ArraySubscription(callback: callback, when: options.when, observable: self)
        subscriptions.append(subscription)
        if options.notifyOnSubscription {
            callback(value, .Initial(elements: value))
        }
        return subscription
    }
    
    func removeSubscription(subscription: ArraySubscription<T>) {
        subscriptions = subscriptions.filter { s in
            s !== subscription
        }
    }
    
    private func notifySubscribersOfChange(change: ArrayChange<T>, when: NotifyWhen) {
        let newValue: [T]
        if when == .BeforeChange {
            // value isn't changed yet, so we need to compute the change
            var updated = value
            
            switch change {
            case let .Initial(elements):
                updated = elements
            case let .Insert(index, newElements):
                updated.insertContentsOf(newElements, at: index)
            case let .Remove(range, _):
                updated.removeRange(range)
            case let .Replace(range, _, newElements):
                updated.replaceRange(range, with: newElements)
            }
            
            newValue = updated
        }
        else {
            newValue = value
        }
        
        
        for subscription in subscriptions where subscription.when == when {
            subscription.callback(newValue, change)
        }
    }
    
}


extension ObservableArray : Indexable, MutableIndexable {
    public typealias _Element = T
    
    public var startIndex: Int {
        return value.startIndex
    }
    
    public var endIndex: Int {
        return value.endIndex
    }
    
    public subscript (position: Int) -> T {
        get {
            return value[position]
        }
        set (value) {
            self.value[position] = value
        }
    }
}

extension ObservableArray : SequenceType {

    @warn_unused_result
    public func generate() -> IndexingGenerator<[T]> {
        return value.generate()
    }

}

extension ObservableArray : CollectionType, MutableCollectionType {
    
}

extension ObservableArray : RangeReplaceableCollectionType {
    public func replaceRange<C : CollectionType where C.Generator.Element == T>(subRange: Range<Int>, with newElements: C) {
        let change = determineChange(subRange, newElements: Array(newElements))
        
        notifySubscribersOfChange(change, when: .BeforeChange)
        value.replaceRange(subRange, with: newElements)
        notifySubscribersOfChange(change, when: .AfterChange)
    }
    
    private func determineChange(subRange: Range<Int>, newElements: [T]) -> ArrayChange<T> {
        if subRange.startIndex == subRange.endIndex {
            return .Insert(index: subRange.startIndex, newElements: newElements)
        }
        else if newElements.count == 0 {
            let removedElements = Array(value[subRange])
            return .Remove(range: subRange, removedElements: removedElements)
        }
        else {
            let removedElements = Array(value[subRange])
            return .Replace(range: subRange, removedElements: removedElements, newElements: newElements)
        }
    }
}
