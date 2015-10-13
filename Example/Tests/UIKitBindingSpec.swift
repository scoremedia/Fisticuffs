//
//  UIKitBindingSpec.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Bindings


class UIKitBindingSpec: QuickSpec {
    override func spec() {
        
        describe("UILabel") {
            it("should support binding it's text value") {
                let name = Observable("")
                
                let label = UILabel()
                label.b_text = name
                
                name.value = "Fred"
                expect(label.text) == "Fred"
            }
        }
        
        describe("UIButton") {
            it("should support binding an action for when the user taps") {
                var receivedTap = false
                
                let button = UIButton()
                button.b_onTap { receivedTap = true }
                
                button.sendActionsForControlEvents(.TouchUpInside)
                
                expect(receivedTap) == true
            }
        }
        
    }
}
