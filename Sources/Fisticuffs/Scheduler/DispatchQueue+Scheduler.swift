//
//  DispatchQueue+Scheduler.swift
//  Fisticuffs
//
//  Created by Eugene Kwong on 2021-04-10.
//  Copyright © 2021 theScore. All rights reserved.
//

import Foundation

extension DispatchQueue: Scheduler {
    public func schedule(_ action: @escaping () -> Void) {
        async {
            action()
        }
    }
}
