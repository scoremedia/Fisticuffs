//
//  ArrayAdapter.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import Foundation

/**
Provides a common interface for:

- ObservableArray<T>
- Observable<[T]>

ObservableArray will provide a much "richer" experience, in that it knows about 
what changes are made, so we can animate those changes on screen. ie, in a table view
we'll use methods like -insertRowsAtIndexPaths:rowAnimation: to make the updates

That being said, sometimes we may wish to bind a basic  Observable<[T]>  to UI elements
(ie., maybe we're binding a Computed<[T]> for filtered search results).  In that case, we
don't quite have enough information to do proper animations,  but we can still bind the 
data.  ie, in a table view we'll use -reloadData to make the updates.

This provides a common interface so our UITableView / UICollectionView code doesn't
need to worry about what its data is wrapped in.
*/
class ArrayAdapter<T> {
    
    //MARK: - Creation
    
    static func forObservable(observable: Observable<[T]>) -> ArrayAdapter<T> {
        return AdapterForObservable(observable: observable)
    }
    
    static func forObservableArray(array: ObservableArray<T>) -> ArrayAdapter<T> {
        return AdapterForObservableArray(array: array)
    }
    
    
    //MARK: - Overrides
    
    func subscribe(callback: ([T], ArrayChange<T>) -> Void) -> Disposable {
        preconditionFailure("Override in subclass")
    }
    
    var count: Int {
        preconditionFailure("Override in subclass")
    }
    
    subscript(index: Int) -> T {
        preconditionFailure("Override in subclass")
    }
    
    func insert(item: T, atIndex index: Int) {
        preconditionFailure("Override in subclass")
    }
    
    func removeAtIndex(index: Int) -> T {
        preconditionFailure("Override in subclass")
    }
    
}

private class AdapterForObservable<T>: ArrayAdapter<T> {
    let observable: Observable<[T]>
    
    init(observable: Observable<[T]>) {
        self.observable = observable
    }
    
    override func subscribe(callback: ([T], ArrayChange<T>) -> Void) -> Disposable {
        return observable.subscribe { items in
            callback(items, .Set(elements: items))
        }
    }
    
    override var count: Int {
        return observable.value.count
    }
    
    override subscript(index: Int) -> T {
        return observable.value[index]
    }
    
    override func insert(item: T, atIndex index: Int) {
        var value = observable.value
        value.insert(item, atIndex: index)
        observable.value = value
    }
    
    override func removeAtIndex(index: Int) -> T {
        var value = observable.value
        let retVal = value.removeAtIndex(index)
        observable.value = value
        return retVal
    }
}

private class AdapterForObservableArray<T>: ArrayAdapter<T> {
    var array: ObservableArray<T>
    
    init(array: ObservableArray<T>) {
        self.array = array
    }
    
    override func subscribe(callback: ([T], ArrayChange<T>) -> Void) -> Disposable {
        return array.subscribeArray(callback)
    }
    
    override var count: Int {
        return array.count
    }
    
    override subscript(index: Int) -> T {
        return array[index]
    }
    
    override func insert(item: T, atIndex index: Int) {
        array.insert(item, atIndex: index)
    }
    
    override func removeAtIndex(index: Int) -> T {
        return array.removeAtIndex(index)
    }
}
