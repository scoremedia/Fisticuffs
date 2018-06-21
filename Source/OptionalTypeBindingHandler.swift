//
//  OptionalTypeBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-16.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

open class OptionalTypeBindingHandler<Control: AnyObject, Data, PropertyValue: OptionalType>: BindingHandler<Control, Data, PropertyValue> {
    typealias InnerHandler = BindingHandler<Control, Data, PropertyValue.Wrapped>

    let innerHandler: InnerHandler

    init(innerHandler: InnerHandler) {
        self.innerHandler = innerHandler

        super.init()

        self.getSubscribable = innerHandler.getSubscribable
    }

    open override func set(control: Control, oldValue: Data?, value: Data, propertySetter: @escaping PropertySetter) {
        let convertedSetter: InnerHandler.PropertySetter = { control, value in
            propertySetter(control, PropertyValue(wrappedValue: value))
        }
        innerHandler.set(control: control, oldValue: oldValue, value: value, propertySetter: convertedSetter)
    }

    open override func get(control: Control, propertyGetter: @escaping PropertyGetter) throws -> Data {
        let innerValue = propertyGetter(control)
        let unwrapped = try innerValue.toUnwrappedValue()

        let convertedGetter: InnerHandler.PropertyGetter = { _ in unwrapped }

        return try innerHandler.get(control: control, propertyGetter: convertedGetter)
    }

    open override func publishValue(_ value: Data) {
        innerHandler.publishValue(value)
    }

    open override func dispose() {
        innerHandler.dispose()
        super.dispose()
    }
}
