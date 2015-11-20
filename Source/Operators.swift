//
//  Operators.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-16.
//
//

//MARK: - Operators

infix operator <-- {}
infix operator --> {}
infix operator <-> {}


//MARK: - One way binding
//MARK: Subscribable's

public func <--<T, S where S: Subscribable, S.ValueType == T>(lhs: Binding<T>, rhs: S) {
    lhs.bind(rhs)
}

public func --><T, S where S: Subscribable, S.ValueType == T>(lhs: S, rhs: Binding<T>) {
    rhs.bind(lhs)
}

public func <--<T, S where S: Subscribable, S.ValueType == T>(lhs: BidirectionalBinding<T>, rhs: S) {
    lhs.bind(rhs)
}

public func --><T, S where S: Subscribable, S.ValueType == T>(lhs: S, rhs: BidirectionalBinding<T>) {
    rhs.bind(lhs)
}

//MARK: Blocks

public func <--<T>(lhs: Binding<T>, rhs: () -> T) {
    lhs.bind(rhs)
}

public func --><T>(lhs: () -> T, rhs: Binding<T>) {
    rhs.bind(lhs)
}

//MARK: - Two way binding

public func <-><T>(lhs: BidirectionalBinding<T>, rhs: Observable<T>) {
    lhs.bind(rhs)
}

public func <-><T>(lhs: Observable<T>, rhs: BidirectionalBinding<T>) {
    rhs.bind(lhs)
}

//MARK: - Subscriptions

public func +=<T, S where S: Subscribable, S.ValueType == T>(lhs: S, rhs: (T?, T) -> Void) {
    lhs.subscribe(rhs)
}

public func +=(lhs: AnySubscribable, rhs: () -> Void) {
    lhs.subscribe(rhs)
}
