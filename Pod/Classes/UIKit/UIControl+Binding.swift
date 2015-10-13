//
//  UIControl+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation


class Action: NSObject, Disposable {
    private weak var actionsState: ActionsState?
    private weak var control: UIControl?
    let events: UIControlEvents
    let action: Void -> Void
    internal init(actionsState: ActionsState, control: UIControl, events: UIControlEvents, action: Void -> Void) {
        self.actionsState = actionsState
        self.control = control
        self.events = events
        self.action = action
        
        super.init()
        
        control.addTarget(self, action: "receiveEvent:", forControlEvents: events)
    }
    
    internal func dispose() {
        if let actionsState = actionsState {
            actionsState.registeredActions = actionsState.registeredActions.filter { action in
                action !== self
            }
        }
        
        if let control = control {
            control.removeTarget(self, action: "receiveEvent:", forControlEvents: events)
        }
    }
    
    @objc func receiveEvent(sender: AnyObject!) {
        action()
    }
}

private var actionsStateKey = 0

internal class ActionsState {
    var registeredActions = [Action]()
}

extension UIControl {
    
    internal var actionsState: ActionsState {
        if let existing = objc_getAssociatedObject(self, &actionsStateKey) as? ActionsState {
            return existing
        }
        else {
            let value = ActionsState()
            objc_setAssociatedObject(self, &actionsStateKey, value, .OBJC_ASSOCIATION_RETAIN)
            return value
        }
    }
    
    
    func b_onTap(actionBlock: Void -> Void) -> Disposable {
        let action = Action(actionsState: actionsState, control: self, events: .TouchUpInside, action: actionBlock)
        actionsState.registeredActions.append(action)
        return action
    }
    
}
