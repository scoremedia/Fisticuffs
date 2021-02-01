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


class BidirectionalBindingSpec: QuickSpec {
    override func spec() {
        describe("BidirectionalBindableProperty") {
            var backingVariable = ""
            var binding: BidirectionalBindableProperty<BidirectionalBindingSpec, String>!
            
            beforeEach {
                binding = BidirectionalBindableProperty(
                    control: self,
                    getter: { _ in backingVariable },
                    setter: { _, value in backingVariable = value }
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
                    let _ = BidirectionalBindableProperty<BidirectionalBindingSpec, Void>(
                        control: self,
                        getter: { _ in },
                        setter: { _, _ in },
                        extraCleanup: DisposableBlock { disposed = true }
                    )
                }
                
                expect(disposed) == true
            }

            it("should prevent value overwrites if a BindingHandler produces different values for its get & set") {
                let observable = Observable(0)
                binding.bind(observable, BindingHandlers.transform({ "\($0)" }, reverse: { (Int($0) ?? 0) * 2 }))

                observable.value = 5

                expect(observable.value) == 5
                expect(backingVariable) == "5"

                backingVariable = "20"
                binding.pushChangeToObservable()

                // Updating the observable (`pushChangeToObservable()`) shouldn't modify `backingVariable` (prevents potential infinite loops)
                expect(backingVariable) == "20"
                expect(observable.value) == 40
            }
        }
    }
}

@available(*, deprecated)
class BidirectionalBindingDeprecatedSpec: QuickSpec {
    override func spec() {
        describe("BidirectionalBindableProperty") {
            var backingVariable = ""
            var binding: BidirectionalBindableProperty<BidirectionalBindingDeprecatedSpec, String>!

            beforeEach {
                binding = BidirectionalBindableProperty(
                    control: self,
                    getter: { _ in backingVariable },
                    setter: { _, value in backingVariable = value }
                )
            }

            it("should support one way binding with a transform") {
                let observable = Observable(11)
                binding.bind(observable, transform: { "\($0)" })
                expect(backingVariable) == "11"
            }
            
            it("should support one way binding to a block") {
                let observable = Observable(10)
                binding.bind { "\(observable.value + 1)" }
                expect(backingVariable) == "11"
            }
        }
    }
}
