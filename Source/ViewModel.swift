//
//  ViewModel.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-19.
//
//

import Foundation


public protocol ViewModel: Equatable {
    
}


public func ==<T where T: ViewModel, T: AnyObject>(lhs: T, rhs: T) -> Bool {
    return lhs === rhs
}
