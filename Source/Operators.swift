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

infix operator <--
infix operator -->
infix operator <->


//MARK: - One way binding
//MARK: Subscribable's

@available(*, deprecated, message: "Use BindableProperty.bind(...) instead")
public func <--<Control, T>(lhs: BindableProperty<Control, T>, rhs: Subscribable<T>) {
    lhs.bind(rhs)
}

@available(*, deprecated, message: "Use BindableProperty.bind(...) instead")
public func --><Control, T>(lhs: Subscribable<T>, rhs: BindableProperty<Control, T>) {
    rhs.bind(lhs)
}

@available(*, deprecated, message: "Use BidirectionalBindableProperty.bind(...) instead")
public func <--<Control: AnyObject, T>(lhs: BidirectionalBindableProperty<Control, T>, rhs: Subscribable<T>) {
    lhs.bind(rhs)
}

@available(*, deprecated, message: "Use BidirectionalBindableProperty.bind(...) instead")
public func --><Control: AnyObject, T>(lhs: Subscribable<T>, rhs: BidirectionalBindableProperty<Control, T>) {
    rhs.bind(lhs)
}

//MARK: Blocks

@available(*, deprecated, message: "Use BindableProperty.bind(...) instead")
public func <--<Control, T>(lhs: BindableProperty<Control, T>, rhs: @escaping () -> T) {
    lhs.bind(rhs)
}

@available(*, deprecated, message: "Use BindableProperty.bind(...) instead")
public func --><Control, T>(lhs: @escaping () -> T, rhs: BindableProperty<Control, T>) {
    rhs.bind(lhs)
}

@available(*, deprecated, message: "Use BidirectionalBindableProperty.bind(...) instead")
public func <--<Control: AnyObject, T>(lhs: BidirectionalBindableProperty<Control, T>, rhs: @escaping () -> T) {
    lhs.bind(rhs)
}

@available(*, deprecated, message: "Use BidirectionalBindableProperty.bind(...) instead")
public func --><Control: AnyObject, T>(lhs: @escaping () -> T, rhs: BidirectionalBindableProperty<Control, T>) {
    rhs.bind(lhs)
}

//MARK: - Two way binding

@available(*, deprecated, message: "Use BindableProperty.bind(...) instead")
public func <-><Control: AnyObject, T>(lhs: BidirectionalBindableProperty<Control, T>, rhs: Observable<T>) {
    lhs.bind(rhs)
}

@available(*, deprecated, message: "Use BindableProperty.bind(...) instead")
public func <-><Control: AnyObject, T>(lhs: Observable<T>, rhs: BidirectionalBindableProperty<Control, T>) {
    rhs.bind(lhs)
}

//MARK: - Subscriptions

@available(*, deprecated, message: "Use Subscribable.subscribe(...) instead")
public func +=<T>(lhs: Subscribable<T>, rhs: @escaping (T?, T) -> Void) {
    lhs.subscribe(rhs)
}

@available(*, deprecated, message: "Use AnySubscribable.subscribe(...) instead")
public func +=(lhs: AnySubscribable, rhs: @escaping () -> Void) {
    lhs.subscribe(rhs)
}
