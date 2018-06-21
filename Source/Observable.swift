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

import Foundation

open class Observable<Value> : Subscribable<Value> {
    
    //MARK: - Value property
    
    open var value: Value {
        set(newValue) {
            let old = storage
            
            subscriptionCollection.notify(time: .beforeChange, old: old, new: newValue)
            subscriptionCollection.notify(time: .valueIsDirty, old: old, new: newValue)
            storage = newValue
            subscriptionCollection.notify(time: .afterChange, old: old, new: storage)
        }
        get {
            DependencyTracker.didReadObservable(self)
            return storage
        }
    }

    open override var currentValue: Value? { return value }
    
    fileprivate var storage: Value

    //MARK: - Init
    public init(_ initial: Value) {
        storage = initial
    }

}
