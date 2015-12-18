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


class OperatorsSpec: QuickSpec {
    override func spec() {
        var observable: Observable<Int>!
        var anySubscribable: AnySubscribable!
        
        var underlyingValue: Int!
        var binding: Binding<Int>!
        var bidirectionalBinding: BidirectionalBinding<Int>!
        
        beforeEach {
            observable = Observable(11)
            anySubscribable = observable
            
            underlyingValue = 0
            binding = Binding<Int>(setter: { value in underlyingValue = value })
            bidirectionalBinding = BidirectionalBinding<Int>(getter: { underlyingValue }, setter: { underlyingValue = $0 })
        }
        
        describe("+=") {
            it("should be used for subscribing to Subscribables") {
                var receivedValue = 0
                observable += { _, new in receivedValue = new }
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
                binding <-- observable
                expect(underlyingValue) == 11
            }
            
            it("should support binding Bindings to blocks (anonymous Computed)") {
                binding <-- { observable.value }
                expect(underlyingValue) == 11
            }
            
            it("should supprt binding BidirectionalBindings to Observables") {
                bidirectionalBinding <-- observable
                expect(underlyingValue) == 11
            }
            
            it("should support binding BidirectionalBindings to blocks (anonymous Computed)") {
                bidirectionalBinding <-- { observable.value }
                expect(underlyingValue) == 11
            }
            
            it("should NOT setup a two-way binding between BidirectionalBindings and Observables") {
                bidirectionalBinding <-- observable
                expect(underlyingValue) == 11
                
                underlyingValue = 5
                bidirectionalBinding.pushChangeToObservable()
                
                // since its a one way binding, should still be 11
                expect(observable.value) == 11
            }
        }
        
        describe("-->") {
            it("should support binding Bindings to Subscribables") {
                observable --> binding
                expect(underlyingValue) == 11
            }
            
            it("should support binding Bindings to blocks (anonymous Computed)") {
                { observable.value } --> binding
                expect(underlyingValue) == 11
            }
            
            it("should supprt binding BidirectionalBindings to Observables") {
                observable --> bidirectionalBinding
                expect(underlyingValue) == 11
            }
            
            it("should support binding BidirectionalBindings to blocks (anonymous Computed)") {
                { observable.value } --> bidirectionalBinding
                expect(underlyingValue) == 11
            }
            
            it("should NOT setup a two-way binding between BidirectionalBindings and Observables") {
                observable --> bidirectionalBinding
                expect(underlyingValue) == 11
                
                underlyingValue = 5
                bidirectionalBinding.pushChangeToObservable()
                
                // since its a one way binding, should still be 11
                expect(observable.value) == 11
            }
        }
        
        describe("<->") {
            it("should support two-way binding between BidirectionalBindings and Observables") {
                bidirectionalBinding <-> observable
                expect(underlyingValue) == 11
                
                underlyingValue = 5
                bidirectionalBinding.pushChangeToObservable()
                
                // since its a one way binding, should still be 11
                expect(observable.value) == 5
            }
        }
    }
}
