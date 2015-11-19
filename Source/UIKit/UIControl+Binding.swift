//
//  UIControl+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import UIKit

public extension UIControl {
    
    var b_enabled: Binding<Bool> {
        get {
            return get("b_enabled", orSet: {
                return Binding<Bool>(setter: { [weak self] value -> Void in
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
