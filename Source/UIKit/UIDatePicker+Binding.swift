//
//  UIDatePicker+Binding.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-19.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit

public extension UIDatePicker {
    var b_date: BidirectionalBinding<NSDate> {
        get {
            return get("b_date", orSet: {
                addTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
                let cleanup = DisposableBlock { [weak self] in
                    self?.removeTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
                }
                
                return BidirectionalBinding<NSDate>(
                    getter: { [weak self] in self?.date ?? NSDate() },
                    setter: { [weak self] value in self?.setDate(value, animated: true) },
                    extraCleanup: cleanup
                )
            })
        }
    }
    
    @objc private func b_valueChanged(sender: UITextField) {
        b_date.pushChangeToObservable()
    }

}
