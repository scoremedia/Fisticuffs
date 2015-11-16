//
//  Subscription.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

public class SubscriptionCollection<T> {
    private var subscriptions = [Subscription<T>]()
    
    func add(when when: NotifyWhen, callback: (T?, T) -> Void) -> Disposable {
        let subscription = Subscription(callback: callback, when: when, subscriptionCollection: self)
        subscriptions.append(subscription)
        return subscription
    }
    
    func notify(time time: NotifyWhen, old: T?, new: T) {
        for s in subscriptions where s.when == time {
            s.callback(old, new)
        }
    }
    
    private func remove(subscription subscription: Subscription<T>) {
        if let index = subscriptions.indexOf(subscription) {
            subscriptions.removeAtIndex(index)
        }
    }
}

private class Subscription<T> : Disposable, Equatable {
    let callback: (T?, T) -> Void
    let when: NotifyWhen
    
    weak var subscriptionCollection: SubscriptionCollection<T>?
    
    init(callback: (T?, T) -> Void, when: NotifyWhen, subscriptionCollection: SubscriptionCollection<T>) {
        self.callback = callback
        self.when = when
        self.subscriptionCollection = subscriptionCollection
    }
    
    func dispose() {
        subscriptionCollection?.remove(subscription: self)
    }
}

private func ==<T>(lhs: Subscription<T>, rhs: Subscription<T>) -> Bool {
    return lhs === rhs
}
