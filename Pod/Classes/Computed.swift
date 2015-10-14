//
//  Computed.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation


public class Computed<T> : Observable<T> {
    
    let valueBlock: Void -> T
    var dependencies = [(AnyObservable, Disposable)]()
    
    public init(block: Void -> T) {
        valueBlock = block
        
        let initial = block()
        super.init(initial)
        
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
        
        for dependency in dependencies {
            let isObserving = self.dependencies.contains { (observable, _) -> Bool in
                return observable === dependency
            }
            
            if isObserving == false {
                var options = SubscriptionOptions()
                options.notifyOnSubscription = false
                let disposable = dependency.subscribeAny(options) { [weak self] in
                    self?.updateValue()
                }
                self.dependencies.append((dependency, disposable))
            }
        }
    }
    
}
