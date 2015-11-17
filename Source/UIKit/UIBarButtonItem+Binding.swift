//
//  UIBarButtonItem+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import Foundation


public extension UIBarButtonItem {
    
    var b_title: Binding<String> {
        get {
            return get("b_title", orSet: {
                return Binding<String>(setter: { [weak self] value in
                    self?.title = value
                })
            })
        }
    }
    
    var b_onTap: Event<Void> {
        return get("b_onTap", orSet: {
            assert(target == nil, "b_onTap cannot co-exist with another target/selector on UIBarButtonItem")
            assert(action == nil, "b_onTap cannot co-exist with another target/selector on UIBarButtonItem")
            
            target = self
            action = "b_receivedOnTap:"
            
            return Event<Void>()
        })
    }
    
    @objc private func b_receivedOnTap(sender: AnyObject) {
        b_onTap.fire()
    }
    
}
