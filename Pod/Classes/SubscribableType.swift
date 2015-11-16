//
//  SubscribableType.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-16.
//
//

public protocol SubscribableType: Subscribable, AnySubscribable {
    var currentValue: ValueType? { get }
    var subscriptionCollection: SubscriptionCollection<ValueType> { get }
}


public protocol Subscribable {
    typealias ValueType
    
    func subscribe(options: SubscriptionOptions, block: (ValueType?, ValueType) -> Void) -> Disposable
    func subscribe(block: (ValueType?, ValueType) -> Void) -> Disposable
}

extension Subscribable {
    public func subscribe(block: (ValueType?, ValueType) -> Void) -> Disposable {
        return subscribe(SubscriptionOptions(), block: block)
    }
}


public protocol AnySubscribable: class {
    func subscribe(options: SubscriptionOptions, block: () -> Void) -> Disposable
    func subscribe(block: () -> Void) -> Disposable
}

extension AnySubscribable {
    public func subscribe(block: () -> Void) -> Disposable {
        return subscribe(SubscriptionOptions(), block: block)
    }
}


extension Subscribable where Self: SubscribableType {
    public func subscribe(options: SubscriptionOptions, block: (ValueType?, ValueType) -> Void) -> Disposable {
        let disposable = subscriptionCollection.add(when: options.when, callback: block)
        if let value = currentValue where options.notifyOnSubscription {
            block(value, value)
        }
        return disposable
    }
}

extension AnySubscribable where Self: SubscribableType {
    public func subscribe(options: SubscriptionOptions, block: () -> Void) -> Disposable {
        let disposable = subscriptionCollection.add(when: options.when) { _, _ in
            block()
        }
        if currentValue != nil && options.notifyOnSubscription {
            block()
        }
        return disposable
    }
}
