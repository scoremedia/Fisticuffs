//
//  UIActivityIndicatorView+Binding.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-04-06.
//  Copyright © 2016 theScore. All rights reserved.
//

import UIKit

private var b_animating_key = 0

public extension UIActivityIndicatorView {

    var b_animating: BindableProperty<UIActivityIndicatorView, Bool> {
        return associatedObjectProperty(self, &b_animating_key) { _ in
            return BindableProperty(self, setter: { control, value in
                switch (control.isAnimating, value) {
                case (false, true):
                    control.startAnimating()
                case (true, false):
                    control.stopAnimating()
                default:
                    break
                }
            })
        }
    }

}
