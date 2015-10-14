//
//  NSObject+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation


private var bindingStateKey = 0

private class BindingState {
    private var activeDisposables = [String: Disposable]()
    private var activeObservables = [String: AnyObject]()  // String: Observer<T>
    
    deinit {
        for (_, disposable) in activeDisposables {
            disposable.dispose()
        }
    }
}

extension NSObject {
    
    private var bindingState: BindingState {
        if let existing = objc_getAssociatedObject(self, &bindingStateKey) as? BindingState {
            return existing
        }
        else {
            let value = BindingState()
            objc_setAssociatedObject(self, &bindingStateKey, value, .OBJC_ASSOCIATION_RETAIN)
            return value
        }
    }
    
    func getObservableFor<T>(key: String) -> Observable<T>? {
        if let observable = bindingState.activeObservables[key] as? Observable<T> {
            return observable
        }
        else {
            return nil
        }
    }
    
    func setObservableFor<T>(key: String, observable: Observable<T>?, setter: (value: T) -> Void) {
        let bindingState = self.bindingState
        
        bindingState.activeObservables.removeValueForKey(key)
        if let old = bindingState.activeDisposables.removeValueForKey(key) {
            old.dispose()
        }
        
        if let observable = observable {
            bindingState.activeObservables[key] = observable
            bindingState.activeDisposables[key] = observable.subscribe(setter)
        }
    }
    
}
