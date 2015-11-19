//
//  UITextField+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import UIKit


public extension UITextField {
    
    var b_text: BidirectionalBinding<String> {
        get {
            return get("b_text", orSet: {
                addTarget(self, action: "b_valueChanged:", forControlEvents: .EditingChanged)
                let cleanup = DisposableBlock { [weak self] in
                    self?.removeTarget(self, action: "b_valueChanged:", forControlEvents: .EditingChanged)
                }
                
                return BidirectionalBinding<String>(
                    getter: { [weak self] in self?.text ?? "" },
                    setter: { [weak self] value in self?.text = value },
                    extraCleanup: cleanup
                )
            })
        }
    }
    
    @objc private func b_valueChanged(sender: UITextField) {
        b_text.pushChangeToObservable()
    }
    
    
    var b_didBeginEditing: Event<UIEvent?> {
        return b_controlEvent(.EditingDidBegin)
    }
    
    var b_didEndEditing: Event<UIEvent?> {
        return b_controlEvent([.EditingDidEnd, .EditingDidEndOnExit])
    }
    
}


public extension UITextField {

    private var b_delegate: TextFieldDelegate {
        return get("b_delegate", orSet: {
            let delegate = TextFieldDelegate()
            self.delegate = delegate
            return delegate
        })
    }
    
    var b_shouldBeginEditing: Binding<Bool> {
        return get("b_shouldBeginEditing", orSet: {
            let delegate = b_delegate
            return Binding { value in
                delegate.shouldBeginEditing = value
            }
        })
    }
    
    var b_shouldEndEditing: Binding<Bool> {
        return get("b_shouldEndEditing", orSet: {
            let delegate = b_delegate
            return Binding { value in
                delegate.shouldEndEditing = value
            }
        })
    }
    
    var b_shouldClear: Binding<Bool> {
        return get("b_shouldClear", orSet: {
            let delegate = b_delegate
            return Binding { value in
                delegate.shouldClear = value
            }
        })
    }
    
    var b_shouldReturn: Binding<Bool> {
        return get("b_shouldReturn", orSet: {
            let delegate = b_delegate
            return Binding { value in
                delegate.shouldReturn = value
            }
        })
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
    
    @objc func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return shouldBeginEditing
    }
    
    @objc func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return shouldEndEditing
    }
    
    @objc func textFieldShouldClear(textField: UITextField) -> Bool {
        let retVal = shouldClear // copy to guard against `shouldClear` being changed in any event subscriptions
        if retVal {
            willClear.fire()
        }
        return retVal
    }
    
    @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
        let retVal = shouldReturn // copy to guard against `shouldReturn` being changed in any event subscriptions
        if retVal {
            willReturn.fire()
        }
        return retVal
    }
    
}
