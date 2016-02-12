//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

//MARK: - Operators

infix operator <-- {}
infix operator --> {}
infix operator <-> {}


//MARK: - One way binding
//MARK: Subscribable's

public func <--<T, S where S: Subscribable, S.ValueType == T>(lhs: BindableProperty<T>, rhs: S) {
    lhs.bind(rhs)
}

public func --><T, S where S: Subscribable, S.ValueType == T>(lhs: S, rhs: BindableProperty<T>) {
    rhs.bind(lhs)
}

public func <--<T, S where S: Subscribable, S.ValueType == T>(lhs: BidirectionalBindableProperty<T>, rhs: S) {
    lhs.bind(rhs)
}

public func --><T, S where S: Subscribable, S.ValueType == T>(lhs: S, rhs: BidirectionalBindableProperty<T>) {
    rhs.bind(lhs)
}

//MARK: Blocks

public func <--<T>(lhs: BindableProperty<T>, rhs: () -> T) {
    lhs.bind(rhs)
}

public func --><T>(lhs: () -> T, rhs: BindableProperty<T>) {
    rhs.bind(lhs)
}

public func <--<T>(lhs: BidirectionalBindableProperty<T>, rhs: () -> T) {
    lhs.bind(rhs)
}

public func --><T>(lhs: () -> T, rhs: BidirectionalBindableProperty<T>) {
    rhs.bind(lhs)
}

//MARK: - Two way binding

public func <-><T>(lhs: BidirectionalBindableProperty<T>, rhs: Observable<T>) {
    lhs.bind(rhs)
}

public func <-><T>(lhs: Observable<T>, rhs: BidirectionalBindableProperty<T>) {
    rhs.bind(lhs)
}

//MARK: - Subscriptions

public func +=<T, S where S: Subscribable, S.ValueType == T>(lhs: S, rhs: (T?, T) -> Void) {
    lhs.subscribe(rhs)
}

public func +=(lhs: AnySubscribable, rhs: () -> Void) {
    lhs.subscribe(rhs)
}
