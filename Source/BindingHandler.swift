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

struct BindingHandlerGetterNotImplemented: ErrorType {}

public class BindingHandler<Control: AnyObject, DataValue, PropertyValue>: Disposable {
    public typealias PropertySetter = (Control, PropertyValue) -> Void
    public typealias PropertyGetter = Control -> PropertyValue

    private weak var control: Control?
    private var propertySetter: PropertySetter?

    private var propertyGetter: PropertyGetter?
    private let getSubscribable: Event<DataValue> = Event()

    private let disposableBag = DisposableBag()

    private var accessingUnderlyingProperty = false

    func setup(control: Control, propertySetter: PropertySetter, subscribable: Subscribable<DataValue>) {
        self.control = control
        self.propertySetter = propertySetter

        subscribable.subscribe { [weak self] oldValue, newValue in
            if self?.accessingUnderlyingProperty == true {
                return
            }

            if let this = self, control = this.control, propertySetter = this.propertySetter {
                this.accessingUnderlyingProperty = true
                this.set(control: control, oldValue: oldValue, value: newValue, propertySetter: propertySetter)
                this.accessingUnderlyingProperty = false
            }
        }
        .addTo(disposableBag)
    }

    func setup(propertyGetter: PropertyGetter, changeEvent: Event<Void>) -> Subscribable<DataValue> {
        self.propertyGetter = propertyGetter

        changeEvent.subscribe { [weak self] _, _ in
            if self?.accessingUnderlyingProperty == true {
                return
            }

            if let this = self, control = this.control, propertyGetter = this.propertyGetter {
                this.accessingUnderlyingProperty = true
                do {
                    let value = try this.get(control: control, propertyGetter: propertyGetter)
                    this.getSubscribable.fire(value)
                } catch {
                    // print a warning maybe?
                }
                this.accessingUnderlyingProperty = false
            }
        }
        return getSubscribable
    }

    public func set(control control: Control, oldValue: DataValue?, value: DataValue, propertySetter: PropertySetter) {
        // Override in subclasses
    }

    public func get(control control: Control, propertyGetter: PropertyGetter) throws -> DataValue {
        // override in subclasses
        throw BindingHandlerGetterNotImplemented()
    }

    public func dispose() {
        disposableBag.dispose()
    }
}
