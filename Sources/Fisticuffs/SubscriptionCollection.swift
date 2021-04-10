//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

open class SubscriptionCollection<T> {
    fileprivate var subscriptions = [Subscription<T>]()
    fileprivate let lock = NSRecursiveLock()
    
    func add(when: NotifyWhen, recieveOn: Scheduler, callback: @escaping (T?, T) -> Void) -> Disposable {
        lock.withLock {
            let subscription = Subscription(callback: callback, when: when, receiveOn: recieveOn, subscriptionCollection: self)
            subscriptions.append(subscription)
            return subscription
        }
    }
    
    public func notify(time: NotifyWhen, old: T?, new: T) {
        lock.withLock {
            for s in subscriptions where s.when == time {
                s.scheduler.schedule {
                    s.callback(old, new)
                }
            }
        }
    }
    
    fileprivate func remove(subscription: Subscription<T>) {
        lock.withLock {
            if let index = subscriptions.firstIndex(of: subscription) {
                subscriptions.remove(at: index)
            }
        }
    }
}

private class Subscription<T> : Disposable, Equatable {
    let callback: (T?, T) -> Void
    let when: NotifyWhen
    let scheduler: Scheduler

    weak var subscriptionCollection: SubscriptionCollection<T>?

    init(callback: @escaping (T?, T) -> Void, when: NotifyWhen, receiveOn: Scheduler, subscriptionCollection: SubscriptionCollection<T>) {
        self.callback = callback
        self.when = when
        self.subscriptionCollection = subscriptionCollection
        self.scheduler = receiveOn
    }

    func dispose() {
        subscriptionCollection?.remove(subscription: self)
    }
}

private func ==<T>(lhs: Subscription<T>, rhs: Subscription<T>) -> Bool {
    lhs === rhs
}
