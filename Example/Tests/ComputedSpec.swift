//
//  ComputedSpec.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


class ComputedSpec: QuickSpec {
    override func spec() {
        describe("Computed") {
            it("should derive its value from the provided block") {
                let a = Observable(11)
                let b = Observable(42)
                
                let sum = Computed { a.value + b.value }
                expect(sum.value) == 53
            }
            
            it("should update its value when any dependencies change") {
                let a = Observable(11)
                let b = Observable(42)
                
                let sum = Computed { a.value + b.value }
                
                a.value = 42
                expect(sum.value) == 84
            }
            
            it("should allow for Observable and Computed dependencies") {
                let a = Observable(11)
                let b = Observable(42)
                
                let sum = Computed { a.value + b.value }
                let display = Computed { "Sum: \(sum.value)" }
                
                a.value = 42
                expect(display.value) == "Sum: 84"
            }
        }
    }
}
