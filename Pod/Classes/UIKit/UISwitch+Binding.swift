//
//  UISwitch+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import Foundation

public extension UISwitch {
    
    var b_on: BidirectionalBinding<Bool> {
        get {
            return get("b_on", orSet: {
                addTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
                let cleanup = DisposableBlock { [weak self] in
                    self?.removeTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
                }
                
                return BidirectionalBinding<Bool>(
                    getter: { [weak self] in self?.on ?? false },
                    setter: { [weak self] value in self?.on = value },
                    extraCleanup: cleanup
                )
            })
        }
    }
    
    @objc private func b_valueChanged(sender: UITextField) {
        b_on.pushChangeToObservable()
    }
}

