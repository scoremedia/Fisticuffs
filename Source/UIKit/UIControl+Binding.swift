//
//  UIControl+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

public extension UIControl {
    
    var b_enabled: Binding<Bool> {
        get {
            return get("b_enabled", orSet: {
                return Binding<Bool>(setter: { [weak self] value -> Void in
                    self?.enabled = value
                })
            })
        }
    }
    
    var b_onTap: Event<Void> {
        return get("b_onTap", orSet: {
            self.addTarget(self, action: "b_receivedOnTap:", forControlEvents: .TouchUpInside)
            return Event<Void>()
        })
    }
    
    @objc private func b_receivedOnTap(sender: AnyObject) {
        b_onTap.fire()
    }
    
}
