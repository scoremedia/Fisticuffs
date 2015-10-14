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


public extension UIControl {
    
    internal var actionsBag: DisposableBag {
        return get("actionsBag", orSet: { DisposableBag() })
    }
    
    var b_enabled: Observable<Bool>? {
        get {
            return getObservableFor("enabled")
        }
        set (value) {
            setObservableFor("enabled", observable: value) {
                [weak self] enabled in
                self?.enabled = enabled
            }
        }
    }
    
    func b_onTap(actionBlock: Void -> Void) -> Disposable {
        let action = ActionWrapper(control: self, events: .TouchUpInside, action: actionBlock)
        actionsBag.add(action)
        return action
    }
    
}
