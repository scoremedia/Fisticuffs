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

private var b_text_key = 0
private var b_attributedText_key = 0
private var b_textColor_key = 0
private var b_textAlignment_key = 0


public extension UILabel {
    
    var b_text: BindableProperty<UILabel, String?> {
        return associatedObjectProperty(self, &b_text_key) { _ in
            return BindableProperty(self, setter: { control, value in
                control.text = value
            })
        }
    }

    var b_attributedText: BindableProperty<UILabel, NSAttributedString?> {
        return associatedObjectProperty(self, &b_attributedText_key) { _ in
            return BindableProperty(self, setter: { control, value in
                control.attributedText = value
            })
        }
    }

    var b_textColor: BindableProperty<UILabel, UIColor?> {
        return associatedObjectProperty(self, &b_textColor_key) { _ in
            return BindableProperty(self, setter: { control, value in
                control.textColor = value
            })
        }
    }

    var b_textAlignment: BindableProperty<UILabel, NSTextAlignment> {
        return associatedObjectProperty(self, &b_textAlignment_key) { _ in
            return BindableProperty(self, setter: { control, value in
                control.textAlignment = value
            })
        }
    }

}
