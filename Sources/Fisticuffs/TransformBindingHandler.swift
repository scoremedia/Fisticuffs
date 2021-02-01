//
//  TransformBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-12.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

private struct NoReverseTransformError: Error {}

open class TransformBindingHandler<Control: AnyObject, InDataValue, OutDataValue, PropertyValue>: BindingHandler<Control, InDataValue, PropertyValue> {

    let bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>
    let transform: (InDataValue) -> OutDataValue
    let reverseTransform: ((OutDataValue) -> InDataValue)?

    init(_ transform: @escaping (InDataValue) -> OutDataValue, reverse: ((OutDataValue) -> InDataValue)?, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>) {
        self.bindingHandler = bindingHandler
        self.transform = transform
        self.reverseTransform = reverse
    }

    open override func set(control: Control, oldValue: InDataValue?, value: InDataValue, propertySetter: @escaping PropertySetter) {
        bindingHandler.set(control: control, oldValue: oldValue.map(transform), value: transform(value), propertySetter: propertySetter)
    }

    open override func get(control: Control, propertyGetter: @escaping PropertyGetter) throws -> InDataValue {
        guard let reverseTransform = reverseTransform else {
            throw NoReverseTransformError()
        }

        let value = try bindingHandler.get(control: control, propertyGetter: propertyGetter)
        return reverseTransform(value)
    }

    override open func dispose() {
        bindingHandler.dispose()
        super.dispose()
    }
}

public extension BindingHandlers {
    static func transform<Control, DataValue, PropertyValue>(_ block: @escaping (DataValue) -> PropertyValue) -> TransformBindingHandler<Control, DataValue, PropertyValue, PropertyValue> {
        TransformBindingHandler(block, reverse: nil, bindingHandler: DefaultBindingHandler())
    }

    static func transform<Control, DataValue, PropertyValue>(_ block: @escaping (DataValue) -> PropertyValue, reverse: @escaping (PropertyValue) -> DataValue) -> TransformBindingHandler<Control, DataValue, PropertyValue, PropertyValue> {
        TransformBindingHandler(block, reverse: reverse, bindingHandler: DefaultBindingHandler())
    }

    static func transform<Control, InDataValue, OutDataValue, PropertyValue>(_ block: @escaping (InDataValue) -> OutDataValue, reverse: ((OutDataValue) -> InDataValue)?, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>)
            -> TransformBindingHandler<Control, InDataValue, OutDataValue, PropertyValue> {
        TransformBindingHandler<Control, InDataValue, OutDataValue, PropertyValue>(block, reverse: reverse, bindingHandler: bindingHandler)
    }
}
