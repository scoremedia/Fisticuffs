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


public class WritableComputed<Value>: Observable<Value> {
    //MARK: -
    public override var value: Value {
        get {
            DependencyTracker.didReadObservable(self)
            return storage
        }
        set(newValue) {
            setter(newValue)
        }
    }
    private var storage: Value

    let getter: Void -> Value
    let setter: Value -> Void

    var dependencies = [(AnySubscribable, Disposable)]()

    public override var currentValue: Value? { return value }

    //MARK: -
    public init(getter: Void -> Value, setter: Value -> Void) {
        storage = getter()
        self.getter = getter
        self.setter = setter
        super.init(storage)
        updateValue()
    }

    deinit {
        for (_, disposable) in dependencies {
            disposable.dispose()
        }
    }

    func setValue(newValue: Value) {
        let oldValue = storage

        subscriptionCollection.notify(time: .BeforeChange, old: oldValue, new: newValue)
        subscriptionCollection.notify(time: .ValueIsDirty, old: oldValue, new: newValue)
        storage = newValue
        subscriptionCollection.notify(time: .AfterChange, old: oldValue, new: newValue)
    }

    func updateValue() {
        var result: Value!
        let dependencies = DependencyTracker.findDependencies {
            result = getter()
        }
        setValue(result)

        for dependency in dependencies where dependency !== self {
            let isObserving = self.dependencies.contains { (observable, _) -> Bool in
                return observable === dependency
            }

            if isObserving == false {
                var options = SubscriptionOptions()
                options.notifyOnSubscription = false
                let disposable = dependency.subscribe(options) { [weak self] in
                    self?.updateValue()
                }
                self.dependencies.append((dependency, disposable))
            }
        }
    }
}
