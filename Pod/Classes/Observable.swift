//
//  Observable.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

public class Observable<T> : NSObject {
    public typealias Observer = (T) -> Void
    
    public var willChange = [Observer]()
    public var didChange = [Observer]()
    
    public var value: T {
        willSet (newValue) {
            willChange.forEach { observer in observer(newValue) }
        }
        didSet {
            didChange.forEach { observer in observer(value) }
        }
    }
    
    public init(_ initial: T) {
        value = initial
    }
}
