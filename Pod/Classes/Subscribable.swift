//
//  Subscribable.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-02.
//
//

public extension Subscribable where ValueType: CollectionType, ValueType.Generator.Element : Equatable {
    
    typealias ItemType = ValueType.Generator.Element
    
    func subscribeArray(options: SubscriptionOptions = SubscriptionOptions(), callback: ([ItemType], ArrayChange<ItemType>) -> Void) -> Disposable {
        return subscribe(options) { oldValue, newValue in
            if let change = oldValue?.calculateChange(newValue) {
                callback(Array(newValue), change)
            }
            else {
                callback(Array(newValue), .Set(elements: Array(newValue)))
            }
        }
    }
    
}
