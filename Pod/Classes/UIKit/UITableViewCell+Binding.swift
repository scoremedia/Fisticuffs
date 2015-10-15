//
//  UITableViewCell+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import UIKit


private var textKey = "text"

public extension UITableViewCell {
    
    var b_accessoryType: Observable<UITableViewCellAccessoryType>? {
        get {
            return getObservableFor("accessoryType")
        }
        set (value) {
            setObservableFor("accessoryType", observable: value) {
                [weak self] accessoryType in
                self?.accessoryType = accessoryType
            }
        }
    }
    
}
