//
//  ArraySubscription.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import Foundation

class ArraySubscription<T> : NSObject, Disposable {
    let callback: ObservableArray<T>.ArrayChangeCallback
    let when: NotifyWhen
    
    // deliberate retain cycle (observable should only die out once all subscribers have been removed)
    private var observable: ObservableArray<T>
    
    internal init(callback: ObservableArray<T>.ArrayChangeCallback, when: NotifyWhen, observable: ObservableArray<T>) {
        self.callback = callback
        self.when = when
        self.observable = observable
    }
    
    internal func dispose() {
        observable.removeSubscription(self)
    }
}

