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
        
        currentBinding = subscribable.subscribe(options) { [weak self] value in
            self?.setter(value)
        }
    }
}
