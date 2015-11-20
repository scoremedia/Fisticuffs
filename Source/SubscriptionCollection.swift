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
