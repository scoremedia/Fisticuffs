//
//  UITextField+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

public extension UITextField {
    
    var b_text: Observable<String>? {
        get {
            return getObservableFor("text")
        }
        set (value) {
            setObservableFor("text", observable: value) {
                [weak self] str in
                if self?.text != str {
                    self?.text = str
                }
            }
            
            if let value = value {
                let editingChanged = ActionWrapper(control: self, events: .EditingChanged) { [weak self, weak value] in
                    guard let text = self?.text else {
                        return
                    }
                    
                    value?.value = text
                }
                set("editingChanged", value: editingChanged)
            }
            else {
                set("editingChanged", value: Optional<ActionWrapper>.None)
            }
        }
    }
}
