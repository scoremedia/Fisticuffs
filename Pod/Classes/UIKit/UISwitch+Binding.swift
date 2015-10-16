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
            setTwoWayBinding("on",
                observable: value,
                valueSetter: { [weak self] on in self?.on = on },
                events: .ValueChanged,
                valueGetter: { [weak self] in self?.on }
            )
        }
    }
}

