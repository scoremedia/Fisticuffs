//
//  BindingSpec.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


class BindingSpec: QuickSpec {
    override func spec() {
        describe("Binding") {
            it("should call its setter when the observed value changes") {
                var backingVariable = ""
                let binding = Binding<String> { value in backingVariable = value }
                
                let observable = Observable("")
                binding.bind(observable)
                
                observable.value = "Test"
                expect(backingVariable) == "Test"
            }
            
            it("should immediately call its setter when bound to a new subscribable") {
                var backingVariable = ""
                let binding = Binding<String> { value in backingVariable = value }
                
                let observable = Observable("Hello")
                binding.bind(observable)
                
                expect(backingVariable) == "Hello"
            }
        }
    }
}
