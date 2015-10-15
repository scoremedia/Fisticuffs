//
//  Observable+Map.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

public extension Observable {
    
    func map<U>(block: (T) -> U) -> Observable<U> {
        return Computed<U> {
            return block(self.value)
        }
    }
    
}
