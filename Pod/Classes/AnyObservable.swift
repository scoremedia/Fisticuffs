//
//  AnyObservable.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

/**
Provides an "untyped" interface to Observable.  Generally only used when we don't
care about the underlying value inside the Observable, we only care about when
it changes (ie. for Computed)
*/
protocol AnyObservable : NSObjectProtocol {
    
    func subscribe(notifyInitially: Bool, callback: (Void) -> Void) -> Disposable
    
}
