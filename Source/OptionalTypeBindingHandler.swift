//
//  OptionalTypeBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-16.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

public class OptionalTypeBindingHandler<Control: AnyObject, Data, PropertyValue: OptionalType>: BindingHandler<Control, Data, PropertyValue> {
    typealias InnerHandler = BindingHandler<Control, Data, PropertyValue.Wrapped>

    let innerHandler: InnerHandler

    init(innerHandler: InnerHandler) {
        self.innerHandler = innerHandler
    }

    public override func set(control control: Control, oldValue: Data?, value: Data, propertySetter: PropertySetter) {
        let convertedSetter: InnerHandler.PropertySetter = { control, value in
            propertySetter(control, PropertyValue(wrappedValue: value))
        }
        innerHandler.set(control: control, oldValue: oldValue, value: value, propertySetter: convertedSetter)
    }
}
