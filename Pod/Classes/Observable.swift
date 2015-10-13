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
    
    public var value: T {
        set(newValue) {
            storage = newValue
            observers.forEach { reference in
                reference.observer(storage)
            }
        }
        get {
            return storage
        }
    }
    
    private var storage: T
    private var observers = [ObserverReference<T>]()
    
    public init(_ initial: T) {
        storage = initial
    }
}

public extension Observable {
    public func addObserver(observer: Observer) -> Disposable {
        let reference = ObserverReference(observer: observer, observable: self)
        observers.append(reference)
        observer(value)
        return reference
    }
}


class ObserverReference<T> : NSObject, Disposable {
    private let observer: Observable<T>.Observer
    private weak var observable: Observable<T>?
    
    private init(observer: Observable<T>.Observer, observable: Observable<T>) {
        self.observer = observer
        self.observable = observable
    }
    
    internal func dispose() {
        guard let observable = observable else {
            return
        }
        
        observable.observers = observable.observers.filter { o in
            o !== self
        }
    }
}

