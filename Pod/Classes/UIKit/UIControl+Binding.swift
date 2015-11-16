//
//  UIControl+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation

class ActionWrapper: NSObject, Disposable {
    
    private weak var control: UIControl?
    private let events: UIControlEvents
    private let action: Void -> Void
    
    init(control: UIControl, events: UIControlEvents, action: Void -> Void) {
        self.control = control
        self.events = events
        self.action = action
        
        super.init()
        
        control.addTarget(self, action: "receivedEvent:", forControlEvents: events)
    }
    
    @objc func receivedEvent(sender: AnyObject) {
        action()
    }
    
    internal func dispose() {
        // NOTE: no need to remove from ActionWrapperBag
        control?.removeTarget(self, action: "receivedEvent:", forControlEvents: events)
    }
    
    deinit {
        dispose()
    }
    
}


extension UIControl {
    
    var actionsBag: DisposableBag {
        return get("actionsBag", orSet: { DisposableBag() })
    }

}

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
    
    func b_onTap(actionBlock: Void -> Void) -> Disposable {
        let action = ActionWrapper(control: self, events: .TouchUpInside, action: actionBlock)
        actionsBag.add(action)
        return action
    }
    
}
