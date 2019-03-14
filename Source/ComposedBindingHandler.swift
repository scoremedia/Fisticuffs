//  The MIT License (MIT)
//
//  Copyright (c) 2019 theScore Inc.
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

/// A `BindingHandler` whose input and output is a function of the two components `BindingHandler`s
class ComposedBindingHandler<Control: AnyObject, InDataValue, OutDataValue, PropertyValue>: BindingHandler<Control, InDataValue, PropertyValue> {
    let bindingHandler1: BindingHandler<Control, InDataValue, OutDataValue>
    let bindingHandler2: BindingHandler<Control, OutDataValue, PropertyValue>
    
    private var bindingHandler1OldValue: OutDataValue?
    
    init(handler1: BindingHandler<Control, InDataValue, OutDataValue>, handler2: BindingHandler<Control, OutDataValue, PropertyValue>) {
        self.bindingHandler1 = handler1
        self.bindingHandler2 = handler2
    }
    
    override func set(control: Control, oldValue: InDataValue?, value: InDataValue, propertySetter: @escaping PropertySetter) {
        bindingHandler1.set(control: control, oldValue: oldValue, value: value) { [handler = self.bindingHandler2, oldValue = bindingHandler1OldValue, weak self] (control, value) in
            handler.set(control: control, oldValue: oldValue, value: value, propertySetter: propertySetter)
            self?.bindingHandler1OldValue = value
        }
    }
    
    override func get(control: Control, propertyGetter: @escaping PropertyGetter) throws -> InDataValue {
        return try bindingHandler1.get(control: control, propertyGetter: { [handler = self.bindingHandler2] (control) -> OutDataValue in
            return try! handler.get(control: control, propertyGetter: propertyGetter)
        })
    }
    
    override func dispose() {
        bindingHandler1.dispose()
        bindingHandler2.dispose()
        super.dispose()
    }
}


///  Composes two `BindingHandler` objcts so that the data flows through the LHS first performing and transfromations and then the RHS
///
/// - Parameters:
///   - lhs: The first binding handler
///   - rhs: the second binding handler
/// - Returns: A binding handle that composes the functions of the two `BindingHandler`s provided
public func && <Control: AnyObject, InDataValue, OutDataValue, PropertyValue>(lhs: BindingHandler<Control, InDataValue, OutDataValue>, rhs:BindingHandler<Control, OutDataValue, PropertyValue>) -> BindingHandler<Control, InDataValue, PropertyValue> {
    return ComposedBindingHandler(handler1: lhs, handler2: rhs)
}
