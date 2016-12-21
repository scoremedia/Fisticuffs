//
//  DispatchSource+Fisticuffs.swift
//  Fisticuffs
//
//  Created by Maksym Korytko on 2016-12-22.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

extension DispatchSource {
    /**
     Creates a timer source and resumes it.
     - parameters:
        - queue: The dispatch queue that should be used to enque the handler.
        - interval: Timer interval since now when the handler should be invoked.
        - leeway: The handler may be called at any time between its scheduled time + leeway.
        - handler: A function that should be called when the timer fires.
     
     - returns: An instance of the DispatchSourceTimer protocol.
                The returned timer will be in the resumed state.
     */
    class func makeScheduledOneshotTimer(
        queue: DispatchQueue = .main,
        interval: DispatchTimeInterval,
        leeway: DispatchTimeInterval = .nanoseconds(0),
        handler: @escaping () -> Void) -> DispatchSourceTimer {

        let timer = DispatchSource.makeTimerSource(queue: queue)

        timer.setEventHandler(handler: handler)
        timer.scheduleOneshot(deadline: DispatchTime.now() + interval)
        timer.resume()

        return timer
    }
}
