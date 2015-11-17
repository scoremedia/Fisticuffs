//
//  EventSpec.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


class EventSpec: QuickSpec {
    override func spec() {
        describe("Event") {
            it("should notify subscribers when fired") {
                var receivedValue: Int? = nil
                
                let event = Event<Int>()
                event.subscribe { _, new in receivedValue = new }
                
                event.fire(11)
                expect(receivedValue) == 11
            }
            
            it("should never fire on subscription") {
                var eventFired = false
                
                let event = Event<Void>()
                event.subscribe { eventFired = true }
                
                expect(eventFired) == false
            }
        }
    }
}
