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

public class BidirectionalBindableProperty<ValueType> {
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

extension BidirectionalBindableProperty {
    // Should be called when something results in the underlying value being changed
    // (ie., when a user types in a UITextField)
    func pushChangeToObservable() {
        currentObservable?.value = getter()
    }
}

public extension BidirectionalBindableProperty {
    // Two way binding
    public func bind(observable: Observable<ValueType>) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true
        
        currentObservable = observable
        currentBinding = observable.subscribe(options) { [weak self] _, value in
            self?.setter(value)
        }
    }
    
    // One way binding
    public func bind<S: Subscribable where S.ValueType == ValueType>(subscribable: S) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true

        currentObservable = nil
        currentBinding = subscribable.subscribe(options) { [weak self] _, value in
            self?.setter(value)
        }
    }
    
    public func bind<S: Subscribable>(subscribable: S, transform: S.ValueType -> ValueType) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true
        
        currentObservable = nil
        currentBinding = subscribable.subscribe(options) { [weak self] _, value in
            self?.setter(transform(value))
        }
    }
    
    public func bind(block: () -> ValueType) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true
        
        var computed: Computed<ValueType>? = Computed<ValueType>(block: block)
        let subscription = computed!.subscribe(options) { [weak self] _, value in
            self?.setter(value)
        }
        
        currentObservable = nil
        currentBinding = DisposableBlock {
            computed = nil // keep a strong reference to the Computed
            subscription.dispose()
        }
    }
}
