//
//  DefaultBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-12.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

public class DefaultBindingHandler<Control: AnyObject, Value>: BindingHandler<Control, Value, Value> {

    public override func set(control control: Control, oldValue: Value?, value: Value, propertySetter: PropertySetter) {
        propertySetter(control, value)
    }
    
}
