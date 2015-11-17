//
//  UISlider+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import Foundation

public extension UISlider {
    
    var b_value: BidirectionalBinding<Float> {
        get {
            return get("b_value", orSet: {
                addTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
                let cleanup = DisposableBlock { [weak self] in
                    self?.removeTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
                }
                
                return BidirectionalBinding<Float>(
                    getter: { [weak self] in self?.value ?? 0.0 },
                    setter: { [weak self] value in self?.value = value },
                    extraCleanup: cleanup
                )
            })
        }
    }
    
    @objc private func b_valueChanged(sender: UITextField) {
        b_value.pushChangeToObservable()
    }
}


