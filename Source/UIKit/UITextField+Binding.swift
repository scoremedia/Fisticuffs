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
private var b_delegate_key = 0
private var b_shouldBeginEditing_key = 0
private var b_shouldEndEditing_key = 0
private var b_shouldClear_key = 0
private var b_shouldReturn_key = 0


public extension UITextField {
    
    var b_text: BidirectionalBindableProperty<UITextField, String?> {
        get {
            return associatedObjectProperty(self, &b_text_key) { _ in
                return TargetActionBindableProperty(
                    control: self,
                    getter: { control in control.text },
                    setter: { control, text in control.text = text },
                    events: .editingChanged
                )
            }
        }
    }

    var b_didBeginEditing: Event<UIEvent?> {
        return b_controlEvent(.editingDidBegin)
    }
    
    var b_didEndEditing: Event<UIEvent?> {
        return b_controlEvent([.editingDidEnd, .editingDidEndOnExit])
    }
    
}


public extension UITextField {

    fileprivate var b_delegate: TextFieldDelegate {
        return associatedObjectProperty(self, &b_delegate_key) { _ in
            let delegate = TextFieldDelegate()
            self.delegate = delegate
            return delegate
        }
    }

    var b_shouldBeginEditing: BindableProperty<UITextField, Bool> {
        return associatedObjectProperty(self, &b_shouldBeginEditing_key) { _ in
            let delegate = b_delegate
            return BindableProperty(self) { control, value in
                delegate.shouldBeginEditing = value
            }
        }
    }

    var b_shouldEndEditing: BindableProperty<UITextField, Bool> {
        return associatedObjectProperty(self, &b_shouldEndEditing_key) { _ in
            let delegate = b_delegate
            return BindableProperty(self) { control, value in
                delegate.shouldEndEditing = value
            }
        }
    }

    var b_shouldClear: BindableProperty<UITextField, Bool> {
        return associatedObjectProperty(self, &b_shouldClear_key) { _ in
            let delegate = b_delegate
            return BindableProperty(self) { control, value in
                delegate.shouldClear = value
            }
        }
    }

    var b_shouldReturn: BindableProperty<UITextField, Bool> {
        return associatedObjectProperty(self, &b_shouldReturn_key) { _ in
            let delegate = b_delegate
            return BindableProperty(self) { control, value in
                delegate.shouldReturn = value
            }
        }
    }

    
    var b_willClear: Event<Void> {
        return b_delegate.willClear
    }
    
    var b_willReturn: Event<Void> {
        return b_delegate.willReturn
    }

}

private class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    let willClear = Event<Void>()
    let willReturn = Event<Void>()
    
    var shouldBeginEditing = true
    var shouldEndEditing = true
    
    var shouldClear = true
    var shouldReturn = true
    
    @objc func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing
    }
    
    @objc func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return shouldEndEditing
    }
    
    @objc func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let retVal = shouldClear // copy to guard against `shouldClear` being changed in any event subscriptions
        if retVal {
            willClear.fire(())
        }
        return retVal
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let retVal = shouldReturn // copy to guard against `shouldReturn` being changed in any event subscriptions
        if retVal {
            willReturn.fire(())
        }
        return retVal
    }
    
}
