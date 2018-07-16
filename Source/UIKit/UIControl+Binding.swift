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


private var b_enabled_key = 0
private var b_onTap_key = 0
private var trampolines_key = 0



public extension UIControl {

    var b_enabled: BindableProperty<UIControl, Bool> {
        get {
            return associatedObjectProperty(self, &b_enabled_key) { _ in
                return BindableProperty(self, setter: { control, value -> Void in
                    control.isEnabled = value
                })
            }
        }
    }

    var b_onTap: Fisticuffs.Event<Void> {
        return associatedObjectProperty(self, &b_onTap_key) { _ in
            self.addTarget(self, action: #selector(self.b_receivedOnTap(_:)), for: .touchUpInside)
            return Fisticuffs.Event<Void>()
        }
    }

    @objc fileprivate func b_receivedOnTap(_ sender: AnyObject) {
        b_onTap.fire(())
    }

}

public extension UIControl {

    /**
     Get an Event<UIEvent?> for the specified events

     - parameter controlEvents: Control events to subscribe to

     - returns: The Event object
     */
    func b_controlEvent(_ controlEvents: UIControlEvents) -> Fisticuffs.Event<UIEvent?> {
        let trampolinesCollection = associatedObjectProperty(self, &trampolines_key) { _ in ControlEventTrampolineCollection() }

        if let trampoline = trampolinesCollection.trampolines[controlEvents.rawValue] {
            return trampoline.event
        } else {
            let trampoline = ControlEventTrampoline()
            addTarget(trampoline, action: #selector(ControlEventTrampoline.receivedEvent(_:uiEvent:)), for: controlEvents)
            trampolinesCollection.trampolines[controlEvents.rawValue] = trampoline
            return trampoline.event
        }
    }

}


private class ControlEventTrampolineCollection: NSObject {
    var trampolines: [UInt: ControlEventTrampoline] = [:]
}

private class ControlEventTrampoline: NSObject {
    let event = Event<UIEvent?>()

    @objc func receivedEvent(_ sender: AnyObject?, uiEvent: UIEvent?) {
        event.fire(uiEvent)
    }
}

