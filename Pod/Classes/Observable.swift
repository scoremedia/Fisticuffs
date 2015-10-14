//
//  Observable.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

public class Observable<T> : NSObject {
    
    public typealias Callback = (T) -> Void
    
    public var value: T {
        set(newValue) {
            for subscription in subscriptions where subscription.when == .BeforeChange {
                subscription.callback(newValue)
            }
            
            storage = newValue
            
            for subscription in subscriptions where subscription.when == .AfterChange {
                subscription.callback(storage)
            }
        }
        get {
            DependencyTracker.didReadObservable(self)
            return storage
        }
    }
    
    private var storage: T
    private var subscriptions = [Subscription<T>]()
    
    public init(_ initial: T) {
        storage = initial
    }
}

public extension Observable {
    public func subscribe(observer: Callback) -> Disposable {
        return subscribe(SubscriptionOptions(), callback: observer)
    }
    
    public func subscribe(options: SubscriptionOptions, callback: Callback) -> Disposable {
        let subscription = Subscription(callback: callback, when: options.when, observable: self)
        subscriptions.append(subscription)
        if options.notifyOnSubscription {
            callback(value)
        }
        return subscription
    }
}

extension Observable {
    func removeSubscription(subscription: Subscription<T>) {
        subscriptions = subscriptions.filter { s in
            s !== subscription
        }
    }
}

extension Observable : AnyObservable {
    func subscribe(options: SubscriptionOptions, callback: (Void) -> Void) -> Disposable {
        return subscribe(options) { (_: T) -> Void in
            callback()
        }
    }
}
