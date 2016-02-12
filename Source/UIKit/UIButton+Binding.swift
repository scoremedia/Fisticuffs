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


private var b_title_key = 0
private var b_image_key = 0
private var b_backgroundImage_key = 0


public extension UIButton {
    
    var b_title: BindableProperty<String> {
        return associatedObjectProperty(self, &b_title_key) { _ in
            return BindableProperty<String>(setter: { [weak self] value in
                self?.setTitle(value, forState: .Normal)
            })
        }
    }

    var b_image: BindableProperty<UIImage> {
        return associatedObjectProperty(self, &b_image_key) { _ in
            return BindableProperty<UIImage>(setter: { [weak self] value in
                self?.setImage(value, forState: .Normal)
            })
        }
    }

    var b_backgroundImage: BindableProperty<UIImage> {
        return associatedObjectProperty(self, &b_backgroundImage_key) { _ in
            return BindableProperty<UIImage>(setter: { [weak self] value in
                self?.setBackgroundImage(value, forState: .Normal)
            })
        }
    }


}
