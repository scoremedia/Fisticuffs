//
//  Observable.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

public class Observable<T> : SubscribableType {
    
    //MARK: - Value property
    
    public var value: T {
        set(newValue) {
            let old = storage
            
            subscriptionCollection.notify(time: .BeforeChange, old: old, new: newValue)
            storage = newValue
            subscriptionCollection.notify(time: .AfterChange, old: old, new: storage)
        }
        get {
            DependencyTracker.didReadObservable(self)
            return storage
        }
    }
    
    private var storage: T
    
    //MARK: - SubscribableType
    public typealias ValueType = T
    public var currentValue: T? { return value }
    public var subscriptionCollection = SubscriptionCollection<T>()

    //MARK: - Init
    public init(_ initial: T) {
        storage = initial
    }

}
