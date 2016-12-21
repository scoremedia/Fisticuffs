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

struct BindingHandlerGetterNotImplemented: Error {}

open class BindingHandler<Control: AnyObject, DataValue, PropertyValue>: Disposable {
    public typealias PropertySetter = (Control, PropertyValue) -> Void
    public typealias PropertyGetter = (Control) -> PropertyValue

    fileprivate weak var control: Control?
    fileprivate var propertySetter: PropertySetter?

    fileprivate var propertyGetter: PropertyGetter?
    fileprivate let getSubscribable: Event<DataValue> = Event()

    fileprivate var accessingUnderlyingProperty = false

    let disposableBag = DisposableBag()

    public init() { // so we can be subclassed outside of Fisticuffs
    }

    func setup(_ control: Control, propertySetter: @escaping PropertySetter, subscribable: Subscribable<DataValue>) {
        self.control = control
        self.propertySetter = propertySetter

        subscribable.subscribe { [weak self] oldValue, newValue in
            if self?.accessingUnderlyingProperty == true {
                return
            }

            if let this = self, let control = this.control, let propertySetter = this.propertySetter {
                this.accessingUnderlyingProperty = true
                this.set(control: control, oldValue: oldValue, value: newValue, propertySetter: propertySetter)
                this.accessingUnderlyingProperty = false
            }
        }
        .addTo(disposableBag)
    }

    func setup(_ propertyGetter: @escaping PropertyGetter, changeEvent: Event<Void>) -> Subscribable<DataValue> {
        self.propertyGetter = propertyGetter

        changeEvent.subscribe { [weak self] _, _ in
            if self?.accessingUnderlyingProperty == true {
                return
            }

            if let this = self, let control = this.control, let propertyGetter = this.propertyGetter {
                this.accessingUnderlyingProperty = true
                do {
                    let value = try this.get(control: control, propertyGetter: propertyGetter)
                    this.getSubscribable.fire(value)
                } catch {
                    // print a warning maybe?
                }
                this.accessingUnderlyingProperty = false
            }
        }.addTo(disposableBag)
        
        return getSubscribable
    }

    open func set(control: Control, oldValue: DataValue?, value: DataValue, propertySetter: @escaping PropertySetter) {
        // Override in subclasses
    }

    open func get(control: Control, propertyGetter: @escaping PropertyGetter) throws -> DataValue {
        // override in subclasses
        throw BindingHandlerGetterNotImplemented()
    }

    open func dispose() {
        disposableBag.dispose()
    }
}
