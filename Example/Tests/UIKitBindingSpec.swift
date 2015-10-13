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
        
    }
}
