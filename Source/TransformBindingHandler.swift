//
//  TransformBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-12.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

public class TransformBindingHandler<Control: AnyObject, InDataValue, OutDataValue, PropertyValue>: BindingHandler<Control, InDataValue, PropertyValue> {
    let bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>
    let transform: InDataValue -> OutDataValue

    init(_ transform: InDataValue -> OutDataValue, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>) {
        self.transform = transform
        self.bindingHandler = bindingHandler
    }

    public override func set(control control: Control, oldValue: InDataValue?, value: InDataValue, propertySetter: PropertySetter) {
        bindingHandler.set(control: control, oldValue: oldValue.map(transform), value: transform(value), propertySetter: propertySetter)
    }
}

public extension BindingHandlers {
    static func transform<Control, DataValue, PropertyValue>(block: DataValue -> PropertyValue) -> TransformBindingHandler<Control, DataValue, PropertyValue, PropertyValue> {
        return TransformBindingHandler(block, bindingHandler: DefaultBindingHandler())
    }

    static func transform<Control, InDataValue, OutDataValue, PropertyValue>(block: InDataValue -> OutDataValue, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>)
            -> TransformBindingHandler<Control, InDataValue, OutDataValue, PropertyValue> {
        return TransformBindingHandler<Control, InDataValue, OutDataValue, PropertyValue>(block, bindingHandler: bindingHandler)
    }
}
