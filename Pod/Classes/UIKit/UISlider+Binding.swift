//
//  UISlider+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import Foundation

public extension UISlider {
    
    var b_value: Observable<Float>? {
        get {
            return getObservableFor("value")
        }
        set (observable) {
            setObservableFor("value", observable: observable) {
                [weak self] value in
                if self?.value != value {
                    self?.value = value
                }
            }
            
            if let observable = observable {
                let valueChanged = ActionWrapper(control: self, events: .ValueChanged) { [weak self, weak observable] in
                    guard let value = self?.value else {
                        return
                    }
                    
                    observable?.value = value
                }
                set("valueChanged", value: valueChanged)
            }
            else {
                set("valueChanged", value: Optional<ActionWrapper>.None)
            }
        }
    }
}


