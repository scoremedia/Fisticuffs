//
//  Observable.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

public class Observable<T> : NSObject {
    
    public typealias Callback = (T, T) -> Void
    
    public var value: T {
        set(newValue) {
            let old = storage
            
            for subscription in subscriptions where subscription.when == .BeforeChange {
                subscription.callback(old, newValue)
            }
            
            storage = newValue
            
            for subscription in subscriptions where subscription.when == .AfterChange {
                subscription.callback(old, storage)
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

    @warn_unused_result(message="Returned Disposable must be used to cancel the subscription")
    public func subscribe(options: SubscriptionOptions = SubscriptionOptions(), callback: T -> Void) -> Disposable {
        return subscribeDiff(options) { _, newValue in
            callback(newValue)
        }
    }
    
    @warn_unused_result(message="Returned Disposable must be used to cancel the subscription")
    public func subscribeDiff(options: SubscriptionOptions = SubscriptionOptions(), callback: Callback) -> Disposable {
        let subscription = Subscription(callback: callback, when: options.when, observable: self)
        subscriptions.append(subscription)
        if options.notifyOnSubscription {
            callback(value, value)
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
    
    @warn_unused_result(message="Returned Disposable must be used to cancel the subscription")
    func subscribeAny(options: SubscriptionOptions, callback: (Void) -> Void) -> Disposable {
        return subscribe(options) { (_: T) -> Void in
            callback()
        }
    }
    
}
