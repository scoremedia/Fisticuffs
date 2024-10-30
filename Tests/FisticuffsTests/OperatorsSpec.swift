//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import Quick
import Nimble
@testable import Fisticuffs


@available(*, deprecated) // bizarre way to silence "deprecated" warnings
class OperatorsSpec: QuickSpec {
    override class func spec() {
        @TestState var subject: OperatorsSpec!
        var currentValueSubscribable: CurrentValueSubscribable<Int>!
        var anySubscribable: AnySubscribable!
        
        var underlyingValue: Int!
        var binding: BindableProperty<OperatorsSpec, Int>!
        var bidirectionalBinding: BidirectionalBindableProperty<OperatorsSpec, Int>!
        
        beforeEach {
            subject = OperatorsSpec()
            currentValueSubscribable = CurrentValueSubscribable(11)
            anySubscribable = currentValueSubscribable
            
            underlyingValue = 0
            binding = BindableProperty<OperatorsSpec, Int>(subject) { _, value in underlyingValue = value }
            bidirectionalBinding = BidirectionalBindableProperty<OperatorsSpec, Int>(control: subject, getter: { _ in underlyingValue }, setter: { _, value in underlyingValue = value })
        }
        
        describe("+=") {
            it("should be used for subscribing to Subscribables") {
                var receivedValue = 0
                currentValueSubscribable += { _, new in receivedValue = new }
                expect(receivedValue) == 11
            }
            
            it("should be used for subscribing to AnySubscribables") {
                var receivedEvent = false
                anySubscribable += { receivedEvent = true }
                expect(receivedEvent) == true
            }
        }
        
        describe("<--") {
            it("should support binding Bindings to Subscribables") {
                binding <-- currentValueSubscribable
                expect(underlyingValue) == 11
            }
            
            it("should support binding Bindings to blocks (anonymous Computed)") {
                binding <-- { currentValueSubscribable.value }
                expect(underlyingValue) == 11
            }
            
            it("should supprt binding BidirectionalBindings to CurrentValueSubscribables") {
                bidirectionalBinding <-- currentValueSubscribable
                expect(underlyingValue) == 11
            }
            
            it("should support binding BidirectionalBindings to blocks (anonymous Computed)") {
                bidirectionalBinding <-- { currentValueSubscribable.value }
                expect(underlyingValue) == 11
            }
            
            it("should NOT setup a two-way binding between BidirectionalBindings and CurrentValueSubscribables") {
                bidirectionalBinding <-- currentValueSubscribable
                expect(underlyingValue) == 11
                
                underlyingValue = 5
                bidirectionalBinding.pushChangeToCurrentValueSubscribable()
                
                // since its a one way binding, should still be 11
                expect(currentValueSubscribable.value) == 11
            }
        }
        
        describe("-->") {
            it("should support binding Bindings to Subscribables") {
                currentValueSubscribable --> binding
                expect(underlyingValue) == 11
            }
            
            it("should support binding Bindings to blocks (anonymous Computed)") {
                { currentValueSubscribable.value } --> binding
                expect(underlyingValue) == 11
            }
            
            it("should supprt binding BidirectionalBindings to CurrentValueSubscribables") {
                currentValueSubscribable --> bidirectionalBinding
                expect(underlyingValue) == 11
            }
            
            it("should support binding BidirectionalBindings to blocks (anonymous Computed)") {
                { currentValueSubscribable.value } --> bidirectionalBinding
                expect(underlyingValue) == 11
            }
            
            it("should NOT setup a two-way binding between BidirectionalBindings and CurrentValueSubscribables") {
                currentValueSubscribable --> bidirectionalBinding
                expect(underlyingValue) == 11
                
                underlyingValue = 5
                bidirectionalBinding.pushChangeToCurrentValueSubscribable()
                
                // since its a one way binding, should still be 11
                expect(currentValueSubscribable.value) == 11
            }
        }
        
        describe("<->") {
            it("should support two-way binding between BidirectionalBindings and CurrentValueSubscribables") {
                bidirectionalBinding <-> currentValueSubscribable
                expect(underlyingValue) == 11
                
                underlyingValue = 5
                bidirectionalBinding.pushChangeToCurrentValueSubscribable()
                
                // since its a one way binding, should still be 11
                expect(currentValueSubscribable.value) == 5
            }
        }
    }
}
