//
//  Subscription.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

class Subscription<T> : NSObject, Disposable {
    let callback: Observable<T>.Callback
    
    // deliberate retain cycle (observable should only die out once all subscribers have been removed)
    private var observable: Observable<T>
    
    internal init(callback: Observable<T>.Callback, observable: Observable<T>) {
        self.callback = callback
        self.observable = observable
    }
    
    internal func dispose() {
        observable.removeSubscription(self)
    }
}

