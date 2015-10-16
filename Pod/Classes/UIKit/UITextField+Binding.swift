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
            setTwoWayBinding("text",
                observable: value,
                valueSetter: { [weak self] str in self?.text = str },
                events: .EditingChanged,
                valueGetter: { [weak self] in self?.text }
            )
        }
    }
    
}
