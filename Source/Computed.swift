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


public class Computed<Value>: Subscribable<Value> {
    
    //MARK: -
    public private(set) var value: Value {
        get {
            if dirty {
                updateValue()
            }

            DependencyTracker.didReadObservable(self)
            return storage
        }
        set(newValue) {
            let oldValue = storage
            
            subscriptionCollection.notify(time: .BeforeChange, old: oldValue, new: newValue)
            storage = newValue
            subscriptionCollection.notify(time: .AfterChange, old: oldValue, new: newValue)
        }
    }
    private var storage: Value

    private var dirty: Bool = false
    private var pendingUpdate: Bool = false
    
    let valueBlock: Void -> Value
    var dependencies = [AnySubscribableBox: Disposable]()
    
    public override var currentValue: Value? { return value }

    //MARK: -
    public init(block: Void -> Value) {
        valueBlock = block

        var result: Value!
        let dependencies = DependencyTracker.findDependencies {
            result = block()
        }
        storage = result

        super.init()

        subscribeToDependencies(dependencies)
    }
    
    deinit {
        for (_, disposable) in dependencies {
            disposable.dispose()
        }
    }

    func setNeedsUpdate() {
        if dirty == false {
            dirty = true
            subscriptionCollection.notify(time: .ValueIsDirty, old: storage, new: storage)
            if pendingUpdate == false {
                pendingUpdate = true
                dispatch_async(dispatch_get_main_queue()) {
                    self.pendingUpdate = false
                    if self.dirty {
                        self.updateValue()
                    }
                }
            }
        }
    }
    
    func updateValue() {
        var result: Value!
        let dependencies = DependencyTracker.findDependencies {
            result = valueBlock()
        }
        dirty = false
        value = result

        subscribeToDependencies(dependencies)
    }

    func subscribeToDependencies(deps: [AnySubscribableBox]) {
        for dependency in deps where dependency.subscribable !== self {
            if dependencies[dependency] == nil {
                var options = SubscriptionOptions()
                options.when = .ValueIsDirty
                options.notifyOnSubscription = false
                let disposable = dependency.subscribable.subscribe(options) { [weak self] in
                    self?.setNeedsUpdate()
                }
                self.dependencies[dependency] = disposable
            }
        }
    }
    
}
