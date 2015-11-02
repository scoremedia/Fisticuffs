//
//  UILabel+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import UIKit


private var textKey = "text"

public extension UILabel {
    
    var b_text: Binding<String> {
        get {
            return get("b_text", orSet: {
                return Binding<String>(setter: { [weak self] value in
                    self?.text = value
                })
            })
        }
    }
    
}
