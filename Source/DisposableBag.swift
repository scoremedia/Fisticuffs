//
//  DisposableBag.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation


public class DisposableBag {
    var disposables = [Disposable]()
    
    deinit {
        for disposable in disposables {
            disposable.dispose()
        }
    }
    
    public func add(disposable: Disposable) {
        disposables.append(disposable)
    }
}


public extension Disposable {
    
    // Convenience method to allow for patterns like:
    //
    //  observable.subscribe { value in
    //      // ... do something here ...
    //  }
    //  .addTo(disposableBag)
    //
    public func addTo(bag: DisposableBag) {
        bag.add(self)
    }
    
}
