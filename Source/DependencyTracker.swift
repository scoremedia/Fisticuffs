//
//  DependencyTracker.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

struct DependencyTracker {
    
    private static var observableReads: [[AnySubscribable]] = []
    
    static func findDependencies(@noescape block: Void -> Void) -> [AnySubscribable] {
        observableReads.append([])
        
        block()
        
        return observableReads.popLast()!
    }
    
    static func didReadObservable(observable: AnySubscribable) {
        if var top = observableReads.last {
            if top.contains({ $0 === observable }) == false {
                top.append(observable)
                observableReads[observableReads.count - 1] = top
            }
        }
    }
    
}
