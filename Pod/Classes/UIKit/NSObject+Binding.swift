//
//  NSObject+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import Foundation


extension NSObject {
    
    func getObservableFor<T>(key: String) -> Observable<T>? {
        return get(key)
    }
    
    func setObservableFor<T>(key: String, observable: Observable<T>?, setter: (value: T) -> Void) {
        set(key, value: observable)
        
        let bag = DisposableBag()
        observable?.subscribe { _, value in setter(value: value) } .addTo(bag)
        set(key, value: bag)
    }
    
}
