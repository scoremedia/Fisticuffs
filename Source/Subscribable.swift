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


public protocol AnySubscribable: class {
    func subscribe(options: SubscriptionOptions, block: () -> Void) -> Disposable
    func subscribe(block: () -> Void) -> Disposable
}


public class Subscribable<Value> : AnySubscribable {
    public var currentValue: Value? {
        return nil
    }

    public let subscriptionCollection: SubscriptionCollection<Value> = SubscriptionCollection()

    public func subscribe(block: (Value?, Value) -> Void) -> Disposable {
        return subscribe(SubscriptionOptions(), block: block)
    }

    public func subscribe(options: SubscriptionOptions, block: (Value?, Value) -> Void) -> Disposable {
        let disposable = subscriptionCollection.add(when: options.when, callback: block)
        if let value = currentValue where options.notifyOnSubscription {
            block(value, value)
        }
        return disposable
    }


    //MARK: AnySubscribable
    public func subscribe(options: SubscriptionOptions, block: () -> Void) -> Disposable {
        return subscribe(options) { _, _ in
            block()
        }
    }

    public func subscribe(block: () -> Void) -> Disposable {
        return subscribe(SubscriptionOptions(), block: block)
    }
}
