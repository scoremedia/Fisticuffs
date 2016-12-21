//
//  ThrottleBindingHandler.swift
//  Fisticuffs
//
//  Created by Maksym Korytko on 2016-12-21.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

/**
 A binding handler that delays notifying the observable of changes in the
 control it's bound to until a timeout expires. Once the timeout expires, this
 binding handler notifies the observable. The value that's passed to the observable
 is the value the control has at the time of the notification. The observable is
 notified once every time a timeout expires.
 
 The delay is applied when a change in the value is propagated from the control to
 the observable only.
 */
open class ThrottleBindingHandler<Control: AnyObject, InDataValue, PropertyValue>: BindingHandler<Control, InDataValue, PropertyValue> {

    private let seconds: Int

    private let bindingHandler: BindingHandler<Control, InDataValue, PropertyValue>
    private let proxyEvent: Event<Void> = Event()

    private var timer: DispatchSourceTimer?

    public init(seconds: Int, bindingHandler: BindingHandler<Control, InDataValue, PropertyValue>) {
        self.seconds = seconds
        self.bindingHandler = bindingHandler
    }

    override func setup(_ propertyGetter: @escaping (Control) -> PropertyValue, changeEvent: Event<Void>) -> Subscribable<InDataValue> {
        changeEvent.subscribe(throttle).addTo(disposableBag)
        return super.setup(propertyGetter, changeEvent: proxyEvent)
    }

    override open func set(control: Control, oldValue: InDataValue?, value: InDataValue, propertySetter: @escaping (Control, PropertyValue) -> Void) {
        bindingHandler.set(control: control, oldValue: oldValue, value: value, propertySetter: propertySetter)
    }

    override open func get(control: Control, propertyGetter: @escaping (Control) -> PropertyValue) throws -> InDataValue {
        return try bindingHandler.get(control: control, propertyGetter: propertyGetter)
    }

    override open func dispose() {
        bindingHandler.dispose()
        timer?.cancel()

        super.dispose()
    }

    private func throttle() {
        timer?.cancel()

        timer = DispatchSource.makeScheduledOneshotTimer(
            interval: .seconds(seconds),
            handler: { [weak self] in self?.proxyEvent.fire() }
        )
    }
}

private class BlockTarget {
    let block: () -> Void

    init(_ block: @escaping () -> Void) {
        self.block = block
    }

    @objc func invokeBlock() {
        block()
    }
}

public extension BindingHandlers {
    static func defaultThrottle<Control, Value>(delayInSeconds seconds: Int) -> ThrottleBindingHandler<Control, Value, Value> {
        return ThrottleBindingHandler(seconds: seconds, bindingHandler: DefaultBindingHandler())
    }
}
