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

public extension UIControl {
    
    var b_enabled: BindableProperty<Bool> {
        get {
            return get("b_enabled", orSet: {
                return BindableProperty<Bool>(setter: { [weak self] value -> Void in
                    self?.enabled = value
                })
            })
        }
    }
    
    var b_onTap: Event<Void> {
        return get("b_onTap", orSet: {
            self.addTarget(self, action: "b_receivedOnTap:", forControlEvents: .TouchUpInside)
            return Event<Void>()
        })
    }
    
    @objc private func b_receivedOnTap(sender: AnyObject) {
        b_onTap.fire()
    }
    
}

public extension UIControl {
    
    /**
     Get an Event<UIEvent?> for the specified events
     
     - parameter controlEvents: Control events to subscribe to
     
     - returns: The Event object
     */
    func b_controlEvent(controlEvents: UIControlEvents) -> Event<UIEvent?> {
        let key = "events_\(controlEvents.rawValue)"
        
        let trampoline = get(key, orSet: { () -> ControlEventTrampoline in
            let trampoline = ControlEventTrampoline()
            addTarget(trampoline, action: "receivedEvent:uiEvent:", forControlEvents: controlEvents)
            print(trampoline.respondsToSelector("receivedEvent:uiEvent:"))
            return trampoline
        })
        
        return trampoline.event
    }
    
}


private class ControlEventTrampoline: NSObject {
    let event = Event<UIEvent?>()
    
    @objc func receivedEvent(sender: AnyObject?, uiEvent: UIEvent?) {
        event.fire(uiEvent)
    }
}
