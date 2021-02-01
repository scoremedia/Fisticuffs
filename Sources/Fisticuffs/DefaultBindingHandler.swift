//
//  DefaultBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-12.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

open class DefaultBindingHandler<Control: AnyObject, Value>: BindingHandler<Control, Value, Value> {

    open override func set(control: Control, oldValue: Value?, value: Value, propertySetter: @escaping PropertySetter) {
        propertySetter(control, value)
    }

    open override func get(control: Control, propertyGetter: @escaping PropertyGetter) throws -> Value {
        propertyGetter(control)
    }
    
}
