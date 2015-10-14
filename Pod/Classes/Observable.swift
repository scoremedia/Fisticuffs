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
            storage = newValue
            subscriptions.forEach { reference in
                reference.callback(storage)
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
        return subscribe(true, callback: observer)
    }
    
    public func subscribe(notifyInitially: Bool, callback: Callback) -> Disposable {
        let subscription = Subscription(callback: callback, observable: self)
        subscriptions.append(subscription)
        if notifyInitially {
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


protocol UntypedObservable: NSObjectProtocol {
    func addUntypedObserver(notifyInitially: Bool, observer: Void -> Void) -> Disposable
}

extension Observable : UntypedObservable {
    public func addUntypedObserver(notifyInitially: Bool, observer: Void -> Void) -> Disposable {
        return subscribe(notifyInitially) { (_: T) -> Void in
            observer()
        }
    }
}
