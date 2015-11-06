//
//  AnySubscribable.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-02.
//
//


/**
Provides an "untyped" interface to Subscribable.  Generally only used when we don't
care about the underlying value inside the Subscribable, we only care about when
it changes (ie. for Computed)
*/
public protocol AnySubscribable: class {
    // Must be implemented
    @warn_unused_result(message="Returned Disposable must be used to cancel the subscription")
    func subscribeAny(options: SubscriptionOptions, callback: () -> Void) -> Disposable
}
