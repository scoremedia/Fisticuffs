//
//  NSLayoutConstraint+Binding.swift
//  Fisticuffs
//
//  Created by Albert Le on 2019-08-28.
//  Copyright © 2019 theScore. All rights reserved.
//

import UIKit

private var b_layout_constraint_active_key = 0 //swiftlint:disable:this identifier_name
private var b_layout_constraint_constant_key = 0 //swiftlint:disable:this identifier_name

extension NSLayoutConstraint {
    //(consistency with fisticuffs)
    //swiftlint:disable:next identifier_name
    public var b_active: BindableProperty<NSLayoutConstraint, Bool> {
        var bindable = objc_getAssociatedObject(self, &b_layout_constraint_active_key) as? BindableProperty<NSLayoutConstraint, Bool>
        if bindable == nil {
            bindable = BindableProperty(self) { this, isActive in
                this.isActive = isActive
            }
            objc_setAssociatedObject(self, &b_layout_constraint_active_key, bindable, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        return bindable! //swiftlint:disable:this force_unwrapping
    }

    //(consistency with fisticuffs)
    //swiftlint:disable:next identifier_name
    public var b_constant: BindableProperty<NSLayoutConstraint, CGFloat> {
        var bindable = objc_getAssociatedObject(self, &b_layout_constraint_constant_key) as? BindableProperty<NSLayoutConstraint, CGFloat>
        if bindable == nil {
            bindable = BindableProperty(self) { this, constant in
                this.constant = constant
            }
            objc_setAssociatedObject(self, &b_layout_constraint_constant_key, bindable, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }

        return bindable! //swiftlint:disable:this force_unwrapping
    }
}

