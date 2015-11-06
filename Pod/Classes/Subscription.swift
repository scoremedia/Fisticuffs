//
//  Subscription.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

class Subscription<T> : NSObject, Disposable {
    let callback: (T?, T) -> Void
    let when: NotifyWhen
    
    // deliberate retain cycle (observable should only die out once all subscribers have been removed)
    private var disposeBlock: () -> Void
    
    internal init(callback: (T?, T) -> Void, when: NotifyWhen, disposeBlock: () -> Void) {
        self.callback = callback
        self.when = when
        self.disposeBlock = disposeBlock
    }
    
    internal func dispose() {
        disposeBlock()
    }
}

