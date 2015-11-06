//
//  BidirectionalBinding.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-02.
//
//

import Foundation

public class BidirectionalBinding<ValueType> {
    typealias Getter = () -> ValueType
    typealias Setter = (ValueType) -> Void
    
    let getter: Getter
    let setter: Setter
    var currentObservable: Observable<ValueType>?
    var currentBinding: Disposable?
    
    // Provides an easy way of setting up additional cleanup that should be done
    // after the binding has died (ie, removing UIControl target-actions, deregistering
    // NSNotifications, deregistering KVO notifications)
    var extraCleanup: Disposable?
    
    
    init(getter: Getter, setter: Setter, extraCleanup: Disposable? = nil) {
        self.getter = getter
        self.setter = setter
        self.extraCleanup = extraCleanup
    }
    
    deinit {
        currentBinding?.dispose()
        extraCleanup?.dispose()
    }
}

extension BidirectionalBinding {
    // Should be called when something results in the underlying value being changed
    // (ie., when a user types in a UITextField)
    func pushChangeToObservable() {
        currentObservable?.value = getter()
    }
}

public extension BidirectionalBinding {
    // Two way binding
    public func bind(observable: Observable<ValueType>) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true
        
        currentObservable = observable
        currentBinding = observable.subscribe(options) { [weak self] value in
            self?.setter(value)
        }
    }
    
    // One way binding
    public func bind<S: Subscribable where S.ValueType == ValueType>(subscribable: S) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true

        currentObservable = nil
        currentBinding = subscribable.subscribe(options) { [weak self] value in
            self?.setter(value)
        }
    }
}
