//
//  UIView+Binding.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-19.
//  Copyright © 2015 theScore. All rights reserved.
//

import Foundation

public extension UIView {
    
    var b_backgroundColor: Binding<UIColor> {
        return get("b_backgroundColor", orSet: {
            return Binding<UIColor>(setter: { [weak self] value in
                self?.backgroundColor = value
            })
        })
    }
    
    var b_hidden: Binding<Bool> {
        return get("b_hidden", orSet: {
            return Binding<Bool>(setter: { [weak self] value in
                self?.hidden = value
            })
        })
    }
    
    var b_alpha: Binding<CGFloat> {
        return get("b_alpha", orSet: {
            return Binding<CGFloat>(setter: { [weak self] value in
                self?.alpha = value
            })
        })
    }
    
    var b_tintColor: Binding<UIColor> {
        return get("b_tintColor", orSet: {
            return Binding<UIColor>(setter: { [weak self] value in
                self?.tintColor = value
            })
        })
    }
    
}
