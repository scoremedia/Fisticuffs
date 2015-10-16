//
//  UIControl+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

class ActionWrapper: NSObject, Disposable {
    
    private weak var control: UIControl?
    private let events: UIControlEvents
    private let action: Void -> Void
    
    init(control: UIControl, events: UIControlEvents, action: Void -> Void) {
        self.control = control
        self.events = events
        self.action = action
        
        super.init()
        
        control.addTarget(self, action: "receivedEvent:", forControlEvents: events)
    }
    
    @objc func receivedEvent(sender: AnyObject) {
        action()
    }
    
    internal func dispose() {
        // NOTE: no need to remove from ActionWrapperBag
        control?.removeTarget(self, action: "receivedEvent:", forControlEvents: events)
    }
    
    deinit {
        dispose()
    }
    
}


extension UIControl {
    
    var actionsBag: DisposableBag {
        return get("actionsBag", orSet: { DisposableBag() })
    }
    
    /**
    Sets up a 2 way binding.
    
    - parameter key:         Key to be used in part when storing the asssociated object
                             It gets namespaced to the be specific to SwiftMVVMBinding & the kind of value being set,
                             so simple strings like "text", "value", "on", etc... are fine
    - parameter observable:  The observable
    - parameter valueSetter: Closure to set the value on the control (make sure to capture self weakly!)
                             i.e.:  setting the .text property on a UITextField
    - parameter events:      Control events that signal the value has changed (ie., the user toggling a switch)
                             *Generally* this is .ValueChanged
    - parameter valueGetter: Closure to get the new value after a control event was received.
                             Make sure to weakly capture self!  Expects an Optional return value for this reason
    */
    func setTwoWayBinding<T>(key: String, observable: Observable<T>?, valueSetter: (T) -> Void, events: UIControlEvents, valueGetter: () -> T?) {
        setObservableFor(key, observable: observable, setter: valueSetter)
        
        let actionKey = "\(key)_valueChanged"
        if let observable = observable {
            let valueChanged = ActionWrapper(control: self, events: events) { [weak observable] in
                if let value = valueGetter() {
                    observable?.value = value
                }
            }
            set(actionKey, value: valueChanged)
        }
        else {
            set(actionKey, value: Optional<ActionWrapper>.None)
        }
    }

}

public extension UIControl {
    
    var b_enabled: Observable<Bool>? {
        get {
            return getObservableFor("enabled")
        }
        set (value) {
            setObservableFor("enabled", observable: value) {
                [weak self] enabled in
                self?.enabled = enabled
            }
        }
    }
    
    func b_onTap(actionBlock: Void -> Void) -> Disposable {
        let action = ActionWrapper(control: self, events: .TouchUpInside, action: actionBlock)
        actionsBag.add(action)
        return action
    }
    
}
