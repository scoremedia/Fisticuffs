//
//  Event.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-16.
//
//

public class Event<T> : SubscribableType {
    
    //MARK: - SubscribableType
    public typealias ValueType = T
    public var currentValue: T? { return nil }
    public var subscriptionCollection = SubscriptionCollection<T>()
    
    
    public func fire(value: T) {
        subscriptionCollection.notify(time: .BeforeChange, old: nil, new: value)
        subscriptionCollection.notify(time: .AfterChange, old: nil, new: value)
    }
    
}
