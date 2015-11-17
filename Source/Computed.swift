//
//  Computed.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation


public class Computed<T>: SubscribableType {
    
    //MARK: -
    public private(set) var value: T {
        get {
            DependencyTracker.didReadObservable(self)
            return storage
        }
        set(newValue) {
            let oldValue = storage
            
            subscriptionCollection.notify(time: .BeforeChange, old: oldValue, new: newValue)
            storage = newValue
            subscriptionCollection.notify(time: .AfterChange, old: oldValue, new: newValue)
        }
    }
    private var storage: T
    
    let valueBlock: Void -> T
    var dependencies = [(AnySubscribable, Disposable)]()
    
    //MARK: - SubscribableType
    public typealias ValueType = T
    public var currentValue: T? { return value }
    public var subscriptionCollection = SubscriptionCollection<T>()

    //MARK: -
    public init(block: Void -> T) {
        storage = block()
        valueBlock = block
        updateValue()
    }
    
    deinit {
        for (_, disposable) in dependencies {
            disposable.dispose()
        }
    }
    
    func updateValue() {
        let dependencies = DependencyTracker.findDependencies {
            value = valueBlock()
        }
        
        for dependency in dependencies where dependency !== self {
            let isObserving = self.dependencies.contains { (observable, _) -> Bool in
                return observable === dependency
            }
            
            if isObserving == false {
                var options = SubscriptionOptions()
                options.notifyOnSubscription = false
                let disposable = dependency.subscribe(options) { [weak self] in
                    self?.updateValue()
                }
                self.dependencies.append((dependency, disposable))
            }
        }
    }
    
}
