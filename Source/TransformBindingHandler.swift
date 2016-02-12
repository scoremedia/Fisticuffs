//
//  TransformBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-12.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

class TransformBindingHandler<Control: AnyObject, InDataValue, OutDataValue, PropertyValue>: BindingHandler<Control, InDataValue, PropertyValue> {
    let bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>
    let transform: InDataValue -> OutDataValue

    init(_ transform: InDataValue -> OutDataValue, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>) {
        self.transform = transform
        self.bindingHandler = bindingHandler
    }

    override func set(control control: Control, oldValue: InDataValue?, value: InDataValue, propertySetter: PropertySetter) {
        bindingHandler.set(control: control, oldValue: oldValue.map(transform), value: transform(value), propertySetter: propertySetter)
    }
}
