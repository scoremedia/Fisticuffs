//
//  Observable+Map.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

public extension Observable {
    
    //TODO: Should look to how KnockoutJS handles 'map' and do something similar to that.
    func map<U>(block: (T) -> U) -> Computed<U> {
        var mapped: Computed<U>? = Computed<U> {
            return block(self.value)
        }
        mapDisposables.add(DisposableBlock {
            mapped = nil
        })
        return mapped!
    }
    
}
