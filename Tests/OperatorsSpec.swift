//
//  OperatorsSpec.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


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
