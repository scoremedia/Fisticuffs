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

open class BidirectionalBindableProperty<Control: AnyObject, ValueType> {
    public typealias Getter = (Control) -> ValueType
    public typealias Setter = (Control, ValueType) -> Void

    weak var control: Control?
    let getter: Getter
    let setter: Setter
    let uiChangeEvent: Event<Void> = Event()
    var currentBinding: Disposable?
    
    // Provides an easy way of setting up additional cleanup that should be done
    // after the binding has died (ie, removing UIControl target-actions, deregistering
    // NSNotifications, deregistering KVO notifications)
    var extraCleanup: Disposable?
    
    
    public init(control: Control, getter: @escaping Getter, setter: @escaping Setter, extraCleanup: Disposable? = nil) {
        self.control = control
        self.getter = getter
        self.setter = setter
        self.extraCleanup = extraCleanup
    }
    
    deinit {
        currentBinding?.dispose()
        extraCleanup?.dispose()
    }
}

extension BidirectionalBindableProperty {
    // Should be called when something results in the underlying value being changed
    // (ie., when a user types in a UITextField)
    public func pushChangeToObservable() {
        uiChangeEvent.fire(())
    }
}

//MARK: - Binding
public extension BidirectionalBindableProperty {
    //MARK: Two way binding
    /// Bind property to observable
    ///
    /// - Parameters:
    ///   - observable: The `Observable`
    ///   - receiveOn: The `Scheduler` for the call back. Defaults to `MainThreadScheduler`
    func bind(_ observable: Observable<ValueType>, receiveOn scheduler: Scheduler = MainThreadScheduler()) {
        bind(observable, DefaultBindingHandler())
    }

    /// Bind property to subscribable
    ///
    /// - Parameters:
    ///   - observable: The `Observable`
    ///   - receiveOn: The `Scheduler` for the call back. Defaults to `MainThreadScheduler`
    ///   - bindingHandler: The custom `BindingHandler`
    func bind<Data>(
        _ observable: Observable<Data>,
        receiveOn scheduler: Scheduler = MainThreadScheduler(),
        _ bindingHandler: BindingHandler<Control, Data, ValueType>
    ) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        let disposables = DisposableBag()

        bindingHandler.setup(control, propertySetter: setter, subscribable: observable, receiveOn: scheduler)
        disposables.add(bindingHandler)

        bindingHandler.setup(getter, changeEvent: uiChangeEvent).subscribe { [weak observable] _, data in
            observable?.value = data
        }.addTo(disposables)

        currentBinding = disposables
    }
    
    //MARK: One way binding

    /// Bind property to subscribable
    ///
    /// - Parameters:
    ///   - subscribable: The `Subscribable`
    ///   - receiveOn: The `Scheduler` for the call back. Defaults to `MainThreadScheduler`
    func bind(_ subscribable: Subscribable<ValueType>, receiveOn scheduler: Scheduler = MainThreadScheduler()) {
        bind(subscribable, DefaultBindingHandler())
    }

    /// Bind property to subscribable
    ///
    /// - Parameters:
    ///   - subscribable: The `Subscribable`
    ///   - receiveOn: The `Scheduler` for the call back. Defaults to `MainThreadScheduler`
    ///   - bindingHandler: The custom `BindingHandler`
    func bind<Data>(
        _ subscribable: Subscribable<Data>,
        receiveOn scheduler: Scheduler = MainThreadScheduler(),
        _ bindingHandler: BindingHandler<Control, Data, ValueType>
    ) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        bindingHandler.setup(control, propertySetter: setter, subscribable: subscribable, receiveOn: scheduler)
        currentBinding = bindingHandler
    }
}

//MARK: - Binding - Optionals
public extension BidirectionalBindableProperty where ValueType: OptionalType {
    //MARK: Two way binding

    /// Bind property to subscribable
    ///
    /// - Parameters:
    ///   - observable: The `Observable`
    ///   - receiveOn: The `Scheduler` for the call back. Defaults to `MainThreadScheduler`
    func bind(_ observable: Observable<ValueType.Wrapped>, receiveOn scheduler: Scheduler = MainThreadScheduler()) {
        bind(observable, receiveOn: scheduler, DefaultBindingHandler())
    }

    /// Bind property to subscribable
    ///
    /// - Parameters:
    ///   - observable: The `Observable`
    ///   - receiveOn: The `Scheduler` for the call back. Defaults to `MainThreadScheduler`
    ///   - bindingHandler: The custom `BindingHandler`
    func bind<Data>(
        _ observable: Observable<Data>,
        receiveOn scheduler: Scheduler = MainThreadScheduler(),
        _ bindingHandler: BindingHandler<Control, Data, ValueType.Wrapped>
    ) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        let disposables = DisposableBag()

        let outerBindingHandler = OptionalTypeBindingHandler<Control, Data, ValueType>(innerHandler: bindingHandler)
        outerBindingHandler.setup(control, propertySetter: setter, subscribable: observable, receiveOn: scheduler)
        disposables.add(outerBindingHandler)

        outerBindingHandler.setup(getter, changeEvent: uiChangeEvent).subscribe { [weak observable] _, data in
            observable?.value = data
        }.addTo(disposables)

        currentBinding = disposables
    }

    //MARK: One way binding

    /// Bind property to subscribable
    ///
    /// - Parameters:
    ///   - subscribable: The `Subscribable`
    ///   - receiveOn: The `Scheduler` for the call back. Defaults to `MainThreadScheduler`
    func bind(_ subscribable: Subscribable<ValueType.Wrapped>, receiveOn scheduler: Scheduler = MainThreadScheduler()) {
        bind(subscribable, DefaultBindingHandler())
    }

    /// Bind property to subscribable
    ///
    /// - Parameters:
    ///   - subscribable: The `Subscribable`
    ///   - receiveOn: The `Scheduler` for the call back. Defaults to `MainThreadScheduler`
    ///   - bindingHandler: The custom `BindingHandler`
    func bind<Data>(
        _ subscribable: Subscribable<Data>,
        receiveOn scheduler: Scheduler = MainThreadScheduler(),
        _ bindingHandler: BindingHandler<Control, Data, ValueType.Wrapped>
    ) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        let outerBindingHandler = OptionalTypeBindingHandler<Control, Data, ValueType>(innerHandler: bindingHandler)

        outerBindingHandler.setup(control, propertySetter: setter, subscribable: subscribable, receiveOn: scheduler)

        currentBinding = outerBindingHandler
    }
}

//MARK: - Deprecated
public extension BidirectionalBindableProperty {
    @available(*, deprecated, message: "Use BidirectionBindableProperty(subscribable, BindingHandlers.transform(...)) instead")
    func bind<OtherType>(_ subscribable: Subscribable<OtherType>, transform: @escaping (OtherType) -> ValueType) {
        bind(subscribable, BindingHandlers.transform(transform))
    }

    @available(*, deprecated, message: "Use a Computed in place of the `block`")
    func bind(_ block: @escaping () -> ValueType) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        var computed: Computed<ValueType>? = Computed<ValueType>(block: block)

        let bindingHandler = DefaultBindingHandler<Control, ValueType>()
        bindingHandler.setup(control, propertySetter: setter, subscribable: computed!)

        currentBinding = DisposableBlock {
            computed = nil // keep a strong reference to the Computed
            bindingHandler.dispose()
        }
    }
}
