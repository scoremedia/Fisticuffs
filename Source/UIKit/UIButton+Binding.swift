//
//  UIButton+Binding.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-19.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit

public extension UIButton {
    
    var b_title: Binding<String> {
        return get("b_title", orSet: {
            return Binding<String>(setter: { [weak self] value in
                self?.setTitle(value, forState: .Normal)
            })
        })
    }

    var b_image: Binding<UIImage> {
        return get("b_image", orSet: {
            return Binding<UIImage>(setter: { [weak self] value in
                self?.setImage(value, forState: .Normal)
            })
        })
    }

    var b_backgroundImage: Binding<UIImage> {
        return get("b_backgroundImage", orSet: {
            return Binding<UIImage>(setter: { [weak self] value in
                self?.setBackgroundImage(value, forState: .Normal)
            })
        })
    }

}
