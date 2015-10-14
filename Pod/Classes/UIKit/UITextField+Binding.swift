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
            let textModified = Action(actionsState: actionsState, control: self, events: .EditingChanged) { [weak self] in
                guard let text = self?.text else {
                    return
                }
                
                value?.value = text
            }
            actionsState.registeredActions.append(textModified)
            
            setObservableFor("text", observable: value) {
                [weak self] str in
                if self?.text != str {
                    self?.text = str
                }
            }
        }
    }
    
}
