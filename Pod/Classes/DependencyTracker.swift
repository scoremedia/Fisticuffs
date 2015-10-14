//
//  DependencyTracker.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

struct DependencyTracker {
    
    private static var observableReads: [[UntypedObservable]] = []
    
    static func findDependencies(@noescape block: Void -> Void) -> [UntypedObservable] {
        observableReads.append([])
        
        block()
        
        return observableReads.popLast()!
    }
    
    static func didReadObservable(observable: UntypedObservable) {
        if var top = observableReads.last {
            if top.contains({ $0 === observable }) == false {
                top.append(observable)
                observableReads[observableReads.count - 1] = top
            }
        }
    }
    
}
