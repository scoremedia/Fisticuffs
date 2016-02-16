//
//  TransformBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-12.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

private struct NoReverseTransformError: ErrorType {}

public class TransformBindingHandler<Control: AnyObject, InDataValue, OutDataValue, PropertyValue>: BindingHandler<Control, InDataValue, PropertyValue> {

    let bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>
    let transform: InDataValue -> OutDataValue
    let reverseTransform: (OutDataValue -> InDataValue)?

    init(_ transform: InDataValue -> OutDataValue, reverse: (OutDataValue -> InDataValue)?, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>) {
        self.bindingHandler = bindingHandler
        self.transform = transform
        self.reverseTransform = reverse
    }

    public override func set(control control: Control, oldValue: InDataValue?, value: InDataValue, propertySetter: PropertySetter) {
        bindingHandler.set(control: control, oldValue: oldValue.map(transform), value: transform(value), propertySetter: propertySetter)
    }

    public override func get(control control: Control, propertyGetter: PropertyGetter) throws -> InDataValue {
        guard let reverseTransform = reverseTransform else {
            throw NoReverseTransformError()
        }

        let value = try bindingHandler.get(control: control, propertyGetter: propertyGetter)
        return reverseTransform(value)
    }
}

public extension BindingHandlers {
    static func transform<Control, DataValue, PropertyValue>(block: DataValue -> PropertyValue) -> TransformBindingHandler<Control, DataValue, PropertyValue, PropertyValue> {
        return TransformBindingHandler(block, reverse: nil, bindingHandler: DefaultBindingHandler())
    }

    static func transform<Control, DataValue, PropertyValue>(block: DataValue -> PropertyValue, reverse: PropertyValue -> DataValue) -> TransformBindingHandler<Control, DataValue, PropertyValue, PropertyValue> {
        return TransformBindingHandler(block, reverse: reverse, bindingHandler: DefaultBindingHandler())
    }

    static func transform<Control, InDataValue, OutDataValue, PropertyValue>(block: InDataValue -> OutDataValue, reverse: (OutDataValue -> InDataValue)?, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>)
            -> TransformBindingHandler<Control, InDataValue, OutDataValue, PropertyValue> {
        return TransformBindingHandler<Control, InDataValue, OutDataValue, PropertyValue>(block, reverse: reverse, bindingHandler: bindingHandler)
    }
}
