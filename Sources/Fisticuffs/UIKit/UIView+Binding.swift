//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

private var b_backgroundColor_key = 0
private var b_hidden_key = 0
private var b_alpha_key = 0
private var b_tintColor_key = 0
private var b_userInteractionEnabled_key = 0


public extension UIView {
    
    var b_backgroundColor: BindableProperty<UIView, UIColor?> {
        associatedObjectProperty(self, &b_backgroundColor_key) { _ in
            BindableProperty(self, setter: { control, value in
                control.backgroundColor = value
            })
        }
    }

    var b_hidden: BindableProperty<UIView, Bool> {
        associatedObjectProperty(self, &b_hidden_key) { _ in
            BindableProperty(self, setter: { control, value in
                control.isHidden = value
            })
        }
    }

    var b_alpha: BindableProperty<UIView, CGFloat> {
        associatedObjectProperty(self, &b_alpha_key) { _ in
            BindableProperty(self, setter: { control, value in
                control.alpha = value
            })
        }
    }

    var b_tintColor: BindableProperty<UIView, UIColor?> {
        associatedObjectProperty(self, &b_tintColor_key) { _ in
            BindableProperty(self, setter: { control, value in
                control.tintColor = value
            })
        }
    }

    var b_userInteractionEnabled: BindableProperty<UIView, Bool> {
        associatedObjectProperty(self, &b_userInteractionEnabled_key) { _ in
            BindableProperty(self, setter: { control, value in
                control.isUserInteractionEnabled = value
            })
        }
    }
}
