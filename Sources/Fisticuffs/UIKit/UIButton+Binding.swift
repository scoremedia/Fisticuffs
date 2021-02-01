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

private var b_attributedTitle_key = 0
private var b_title_key = 0
private var b_image_key = 0
private var b_backgroundImage_key = 0
private var b_titleColor_key = 0

public extension UIButton {

    var b_attributedTitle: BindableProperty<UIButton, NSAttributedString?> {
        associatedObjectProperty(self, &b_attributedTitle_key) { _ in
            BindableProperty(self) { control, value in
                control.setAttributedTitle(value, for: UIControl.State())
            }
        }
    }

    var b_title: BindableProperty<UIButton, String?> {
        associatedObjectProperty(self, &b_title_key) { _ in
            BindableProperty(self) { control, value in
                control.setTitle(value, for: UIControl.State())
            }
        }
    }

    var b_image: BindableProperty<UIButton, UIImage?> {
        associatedObjectProperty(self, &b_image_key) { _ in
            BindableProperty(self) { control, value in
                control.setImage(value, for: UIControl.State())
            }
        }
    }

    var b_backgroundImage: BindableProperty<UIButton, UIImage?> {
        associatedObjectProperty(self, &b_backgroundImage_key) { _ in
            BindableProperty(self) { control, value in
                control.setBackgroundImage(value, for: UIControl.State())
            }
        }
    }

    var b_titleColor: BindableProperty<UIButton, UIColor?> {
        associatedObjectProperty(self, &b_titleColor_key) { _ in
            BindableProperty(self) { control, value in
                control.setTitleColor(value, for: UIControl.State())
            }
        }
    }
}
