//
//  UISwitch+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import Foundation

public extension UISwitch {
    
    var b_on: Observable<Bool>? {
        get {
            return getObservableFor("on")
        }
        set (value) {
            setObservableFor("on", observable: value) {
                [weak self] on in
                if self?.on != on {
                    self?.on = on
                }
            }
            
            if let value = value {
                let valueChanged = ActionWrapper(control: self, events: .ValueChanged) { [weak self, weak value] in
                    guard let on = self?.on else {
                        return
                    }
                    
                    value?.value = on
                }
                set("valueChanged", value: valueChanged)
            }
            else {
                set("valueChanged", value: Optional<ActionWrapper>.None)
            }
        }
    }
}

