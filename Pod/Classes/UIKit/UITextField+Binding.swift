//
//  UITextField+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

public extension UITextField {
    
    var b_text: BidirectionalBinding<String> {
        get {
            return get("b_text", orSet: {
                addTarget(self, action: "b_valueChanged:", forControlEvents: .EditingChanged)
                let cleanup = DisposableBlock { [weak self] in
                    self?.removeTarget(self, action: "b_valueChanged:", forControlEvents: .EditingChanged)
                }
                
                return BidirectionalBinding<String>(
                    getter: { [weak self] in self?.text ?? "" },
                    setter: { [weak self] value in self?.text = value },
                    extraCleanup: cleanup
                )
            })
        }
    }
    
    @objc private func b_valueChanged(sender: UITextField) {
        b_text.pushChangeToObservable()
    }
}
