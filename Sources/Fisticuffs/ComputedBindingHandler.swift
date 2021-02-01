//
//  ComputedBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-05-05.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

//TODO: Make all binding handlers refresh when a computed value changes
open class ComputedBindingHandler<Control: AnyObject, InDataValue, OutDataValue, PropertyValue>: BindingHandler<Control, InDataValue, PropertyValue> {

    let bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>
    let transform: (InDataValue) -> OutDataValue

    let inValue: Observable<InDataValue?> = Observable(nil)
    var computed: Computed<OutDataValue?>!

    var subscription: Disposable? = nil

    init(_ transform: @escaping (InDataValue) -> OutDataValue, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>) {
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

    open override func set(control: Control, oldValue: InDataValue?, value: InDataValue, propertySetter: @escaping PropertySetter) {
        subscription?.dispose()

        // so we get oldValue/newValue information, we'll notifyOnSubscription = false, then set it to the new value after
        let opts = SubscriptionOptions(notifyOnSubscription: false, when: .afterChange)
        subscription = computed.subscribe(opts) { [weak self, weak control] oldValue, newValue in
            if let bindingHandler = self?.bindingHandler, let control = control, let oldValue = oldValue, let newValue = newValue {
                bindingHandler.set(control: control, oldValue: oldValue, value: newValue, propertySetter: propertySetter)
            }
        }
        inValue.value = value

        // Force an update right away (instead of waiting for next runloop) so that we don't leave old data on screen.  This is especially
        // important for table view/collection view cells where views are reused.
        computed.updateValue()
    }

    override open func dispose() {
        bindingHandler.dispose()
        super.dispose()
    }
}

public extension BindingHandlers {
    static func computed<Control, DataValue, PropertyValue>(_ block: @escaping (DataValue) -> PropertyValue) -> ComputedBindingHandler<Control, DataValue, PropertyValue, PropertyValue> {
        ComputedBindingHandler(block, bindingHandler: DefaultBindingHandler())
    }

    static func computed<Control, InDataValue, OutDataValue, PropertyValue>(_ block: @escaping (InDataValue) -> OutDataValue, reverse: ((OutDataValue) -> InDataValue)?, bindingHandler: BindingHandler<Control, OutDataValue, PropertyValue>)
        -> ComputedBindingHandler<Control, InDataValue, OutDataValue, PropertyValue> {
            ComputedBindingHandler<Control, InDataValue, OutDataValue, PropertyValue>(block, bindingHandler: bindingHandler)
    }
}
