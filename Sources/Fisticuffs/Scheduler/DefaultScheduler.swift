//
//  DefaultScheduler.swift
//  Fisticuffs
//
//  Created by Eugene Kwong on 2021-04-10.
//  Copyright © 2021 theScore. All rights reserved.
//

import Foundation

public final class DefaultScheduler: Scheduler {
    public init() {}

    public func schedule(_ action: @escaping () -> Void) {
        action()
    }
}
