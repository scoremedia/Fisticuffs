//  The MIT License (MIT)
//
//  Copyright (c) 2016 theScore Inc.
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


open class WritableComputed<Value>: Observable<Value> {
    //MARK: -
    open override var value: Value {
        get {
            if dirty {
                updateValue()
            }

            DependencyTracker.didReadObservable(self)
            return storage
        }
        set(newValue) {
            setter(newValue)
        }
    }
    fileprivate var storage: Value

    fileprivate var dirty: Bool = false
    fileprivate var pendingUpdate: Bool = false

    let getter: () -> Value
    let setter: (Value) -> Void

    var dependencies = [AnySubscribableBox: Disposable]()

    open override var currentValue: Value? { return value }

    //MARK: -
    public init(getter: @escaping () -> Value, setter: @escaping (Value) -> Void) {
        var result: Value!
        let dependencies = DependencyTracker.findDependencies {
            result = getter()
        }
        storage = result

        self.getter = getter
        self.setter = setter
        super.init(storage)

        subscribeToDependencies(dependencies)
    }

    deinit {
        for (_, disposable) in dependencies {
            disposable.dispose()
        }
    }

    func setValue(_ newValue: Value) {
        let oldValue = storage

        subscriptionCollection.notify(time: .beforeChange, old: oldValue, new: newValue)
        storage = newValue
        subscriptionCollection.notify(time: .afterChange, old: oldValue, new: newValue)
    }

    func setNeedsUpdate() {
        if dirty == false {
            dirty = true
            subscriptionCollection.notify(time: .valueIsDirty, old: storage, new: storage)
            if pendingUpdate == false {
                pendingUpdate = true
                DispatchQueue.main.async {
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
            result = getter()
        }
        dirty = false
        setValue(result)

        subscribeToDependencies(dependencies)
    }

    func subscribeToDependencies(_ deps: [AnySubscribableBox]) {
        for dependency in deps where dependency.subscribable !== self {
            if dependencies[dependency] == nil {
                var options = SubscriptionOptions()
                options.when = .valueIsDirty
                options.notifyOnSubscription = false
                let disposable = dependency.subscribable.subscribe(options) { [weak self] in
                    self?.setNeedsUpdate()
                }
                self.dependencies[dependency] = disposable
            }
        }
    }
}
