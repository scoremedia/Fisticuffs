//
//  Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-02.
//
//

public class Binding<ValueType> {
    typealias Setter = (ValueType) -> Void
    
    
    let setter: Setter
    var currentBinding: Disposable?
    
    init(setter: Setter) {
        self.setter = setter
    }
    
    deinit {
        currentBinding?.dispose()
    }
}

public extension Binding {
    public func bind<S: Subscribable where S.ValueType == ValueType>(subscribable: S) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true
        
        currentBinding = subscribable.subscribe(options) { [weak self] _, value in
            self?.setter(value)
        }
    }
    
    public func bind<S: Subscribable>(subscribable: S, transform: S.ValueType -> ValueType) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true
        
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
        
        currentBinding = DisposableBlock {
            computed = nil // keep a strong reference to the Computed
            subscription.dispose()
        }
    }
}
