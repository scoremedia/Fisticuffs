//
//  RunLoop+Scheduler.swift
//  Fisticuffs
//
//  Created by Eugene Kwong on 2021-04-10.
//  Copyright © 2021 theScore. All rights reserved.
//

import Foundation

extension RunLoop: Scheduler {
    public func schedule(_ action: @escaping () -> Void) {
        if #available(iOS 10.0, *) {
            perform {
                action()
            }
        }
        else {
            CFRunLoopPerformBlock(getCFRunLoop(), CFRunLoopMode.defaultMode.rawValue) {
                action()
            }
        }
    }
}
