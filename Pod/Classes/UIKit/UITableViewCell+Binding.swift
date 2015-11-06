//
//  UITableViewCell+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import UIKit


public extension UITableViewCell {
    
    var b_accessoryType: Binding<UITableViewCellAccessoryType> {
        get {
            return get("b_accessoryType", orSet: {
                return Binding<UITableViewCellAccessoryType>(setter: { [weak self] value in
                    self?.accessoryType = value
                })
            })
        }
    }
    
}
