//
//  ComputedBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-05-05.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

//TODO: Make all binding handlers refresh when a computed value changes
public class ComputedBindingHandler<Control: AnyObject, InDataValue, OutDataValue, PropertyValue>: BindingHandler<Control, InDataValue, PropertyValue> {

    let bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>
    let transform: InDataValue -> OutDataValue

    let inValue: Observable<InDataValue?> = Observable(nil)
    var computed: Computed<OutDataValue?>!

    var subscription: Disposable? = nil

    init(_ transform: InDataValue -> OutDataValue, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>) {
        self.bindingHandler = bindingHandler
        self.transform = transform

        super.init()

        self.computed = Computed { [weak self] in
            if let inValue = self?.inValue.value {
                return transform(inValue)
            }
            else {
                return nil
            }
        }
    }

    deinit {
        subscription?.dispose()
    }

    public override func set(control control: Control, oldValue: InDataValue?, value: InDataValue, propertySetter: PropertySetter) {
        subscription?.dispose()

        // so we get oldValue/newValue information, we'll notifyOnSubscription = false, then set it to the new value after
        let opts = SubscriptionOptions(notifyOnSubscription: false, when: .AfterChange)
        subscription = computed.subscribe(opts) { [weak self, weak control] oldValue, newValue in
            if let bindingHandler = self?.bindingHandler, control = control, oldValue = oldValue, newValue = newValue {
                bindingHandler.set(control: control, oldValue: oldValue, value: newValue, propertySetter: propertySetter)
            }
        }
        inValue.value = value
    }

    override public func dispose() {
        bindingHandler.dispose()
        super.dispose()
    }
}

public extension BindingHandlers {
    static func computed<Control, DataValue, PropertyValue>(block: DataValue -> PropertyValue) -> ComputedBindingHandler<Control, DataValue, PropertyValue, PropertyValue> {
        return ComputedBindingHandler(block, bindingHandler: DefaultBindingHandler())
    }

    static func computed<Control, InDataValue, OutDataValue, PropertyValue>(block: InDataValue -> OutDataValue, reverse: (OutDataValue -> InDataValue)?, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>)
        -> ComputedBindingHandler<Control, InDataValue, OutDataValue, PropertyValue> {
            return ComputedBindingHandler<Control, InDataValue, OutDataValue, PropertyValue>(block, bindingHandler: bindingHandler)
    }
}
