//
//  Computed.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

private var observableReads: [[UntypedObservable]] = []

func didReadObservable(observable: UntypedObservable) {
    if var top = observableReads.last {
        if top.contains({ $0 !== observable }) == false {
            top.append(observable)
            observableReads[observableReads.count - 1] = top
        }
    }
}


public class Computed<T> : Observable<T> {
    
    let valueBlock: Void -> T
    
    public init(block: Void -> T) {
        valueBlock = block
        
        let (initial, dependencies) = Computed.evalBlock(block)
        super.init(initial)
        
        for dependency in dependencies {
            dependency.addUntypedObserver { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.value = strongSelf.valueBlock()
            }
        }
    }
    
    static func evalBlock(block: Void -> T) -> (T, [UntypedObservable]) {
        observableReads.append([])
        let value = block()
        let dependencies = observableReads.popLast()!
        return (value, dependencies)
    }
    
}
