//
//  BidirectionalBindingSpec.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


class BidirectionalBindingSpec: QuickSpec {
    override func spec() {
        describe("BidirectionalBinding") {
            var backingVariable = ""
            var binding: BidirectionalBinding<String>!
            
            beforeEach {
                binding = BidirectionalBinding(
                    getter: { backingVariable },
                    setter: { value in backingVariable = value }
                )
            }
            
            it("should call its setter when the observed value changes") {
                let observable = Observable("")
                binding.bind(observable)
                
                observable.value = "Test"
                expect(backingVariable) == "Test"
            }
            
            it("should immediately call its setter when bound to a new subscribable") {
                let observable = Observable("Hello")
                binding.bind(observable)
                
                expect(backingVariable) == "Hello"
            }
            
            it("should update the bound Observable when its value changes") {
                let observable = Observable("")
                binding.bind(observable)
                
                backingVariable = "Hello world"
                binding.pushChangeToObservable()
                
                expect(observable.value) == "Hello world"
            }
            
            it("should support one way binding to Computed") {
                let observable = Observable(11)
                let computed = Computed { "\(observable.value)" }
                
                binding.bind(computed)
                expect(backingVariable) == "11"
            }
            
            it("should support additional cleanup on deinit") {
                var disposed = false
                
                autoreleasepool {
                    let _ = BidirectionalBinding<Void>(
                        getter: { },
                        setter: { },
                        extraCleanup: DisposableBlock { disposed = true }
                    )
                }
                
                expect(disposed) == true
            }
        }
    }
}

