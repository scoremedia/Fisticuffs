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
            setTwoWayBinding("value",
                observable: observable,
                valueSetter: { [weak self] v in self?.value = v },
                events: .ValueChanged,
                valueGetter: { [weak self] in self?.value }
            )
        }
    }
}


