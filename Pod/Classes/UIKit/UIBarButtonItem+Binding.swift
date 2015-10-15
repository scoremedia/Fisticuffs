//
//  UIBarButtonItem+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import Foundation

class BarButtonItemActionWrapper: NSObject, Disposable {
    
    private weak var barButtonItem: UIBarButtonItem?
    private let action: Void -> Void
    
    init(barButtonItem: UIBarButtonItem, action: Void -> Void) {
        self.barButtonItem = barButtonItem
        self.action = action
        
        super.init()
        
        barButtonItem.target = self
        barButtonItem.action = "receivedEvent:"
    }
    
    @objc func receivedEvent(sender: AnyObject) {
        action()
    }
    
    func dispose() {
        // NOTE: no need to remove from ActionWrapperBag
        if barButtonItem?.target === self {
            barButtonItem?.target = nil
            barButtonItem?.action = nil
        }
    }
    
    deinit {
        dispose()
    }
    
}


public extension UIControl {
    
}


public extension UIBarButtonItem {
    
    internal var actionsBag: DisposableBag {
        return get("actionsBag", orSet: { DisposableBag() })
    }
    
    func b_onTap(actionBlock: Void -> Void) -> Disposable {
        let action = BarButtonItemActionWrapper(barButtonItem: self, action: actionBlock)
        actionsBag.add(action)
        return action
    }
    
    var b_title: Observable<String>? {
        get {
            return getObservableFor("title")
        }
        set (value) {
            setObservableFor("title", observable: value) {
                [weak self] title in
                self?.title = title
            }
        }
    }
    
}
