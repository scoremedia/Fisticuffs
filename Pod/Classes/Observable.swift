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
            DependencyTracker.didReadObservable(self)
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
        return addObserver(true, observer: observer)
    }
    
    public func addObserver(notifyInitially: Bool, observer: Observer) -> Disposable {
        let reference = ObserverReference(observer: observer, observable: self)
        observers.append(reference)
        if notifyInitially {
            observer(value)
        }
        return reference
    }
}

protocol UntypedObservable: NSObjectProtocol {
    func addUntypedObserver(notifyInitially: Bool, observer: Void -> Void) -> Disposable
}

extension Observable : UntypedObservable {
    public func addUntypedObserver(notifyInitially: Bool, observer: Void -> Void) -> Disposable {
        return addObserver(notifyInitially) { (_: T) -> Void in
            observer()
        }
    }
}


class ObserverReference<T> : NSObject, Disposable {
    private let observer: Observable<T>.Observer
    // deliberate retain cycle (observable should only die out once all subscribers have been removed)
    private var observable: Observable<T>
    
    private init(observer: Observable<T>.Observer, observable: Observable<T>) {
        self.observer = observer
        self.observable = observable
    }
    
    internal func dispose() {
        observable.observers = observable.observers.filter { o in
            o !== self
        }
    }
}

