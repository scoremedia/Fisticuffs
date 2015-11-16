//
//  Observable.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

public class Observable<T> : AnySubscribable, Subscribable, SubscribableMixin {
    
    //MARK: - Value property
    
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
    
    //MARK: - SubscribableMixin Storage
    
    var currentValue: T? {
        return value
    }
    var subscriptions = [Subscription<T>]()
    
    //MARK: - 
    
    // To keep a strong reference to Computed's returned by .map(...)
    var mapDisposables = DisposableBag()
    
    //MARK: - Init
    
    public init(_ initial: T) {
        storage = initial
    }

}

//MARK: - Subscribable
extension Observable {
    @warn_unused_result(message="Returned Disposable must be used to cancel the subscription")
    public func subscribeDiff(options: SubscriptionOptions = SubscriptionOptions(), callback: (T?, T) -> Void) -> Disposable {
        return addSubscription(options, callback: callback)
    }
}

//MARK: - AnySubscribable
extension Observable {
    @warn_unused_result(message="Returned Disposable must be used to cancel the subscription")
    public func subscribeAny(options: SubscriptionOptions = SubscriptionOptions(), callback: () -> Void) -> Disposable {
        return addSubscription(options) { _, _ in
            callback()
        }
    }
}