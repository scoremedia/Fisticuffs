//
//  NSLocking+Fisticuffs.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-07-04.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

extension NSLocking {
    func withLock<T>(@noescape block: Void -> T) -> T {
        lock()
        let result = block()
        unlock()
        return result
    }
}
