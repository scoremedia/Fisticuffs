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


class BindablePropertySpec: QuickSpec {
    override class func spec() {
        @TestState var subject: BindablePropertySpec!

        beforeEach {
            subject = BindablePropertySpec()
        }

        describe("BindableProperty") {
            it("should call its setter when the observed value changes") {
                var backingVariable = ""
                let binding = BindableProperty<BindablePropertySpec, String>(subject) { _, value in backingVariable = value }

                let currentValueSubscribable = CurrentValueSubscribable("")
                binding.bind(currentValueSubscribable)
                
                currentValueSubscribable.value = "Test"
                expect(backingVariable) == "Test"
            }
            
            it("should immediately call its setter when bound to a new subscribable") {
                var backingVariable = ""
                let binding = BindableProperty<BindablePropertySpec, String>(subject) { _, value in backingVariable = value }

                let currentValueSubscribable = CurrentValueSubscribable("Hello")
                binding.bind(currentValueSubscribable)
                
                expect(backingVariable) == "Hello"
            }

            it("should call its setter on the main thread") {
                var callingThreads = [Thread]()

                let binding = BindableProperty<BindablePropertySpec, String>(subject) { _, value in
                    callingThreads.append(Thread.current)
                }

                let currentValueSubscribable = CurrentValueSubscribable("")
                binding.bind(currentValueSubscribable)

                let backgroundQueue = DispatchQueue(label: "background")

                backgroundQueue.async {
                    currentValueSubscribable.value = "Test"
                }

                expect(callingThreads.count).toEventually(equal(2))
                expect { callingThreads.allSatisfy { $0.isMainThread } }.to(beTrue())
            }
        }
    }
}

@available(*, deprecated)
class BindablePropertyDeprecatedSpec: QuickSpec {
    override class func spec() {
        @TestState var subject: BindablePropertyDeprecatedSpec!

        beforeEach {
            subject = BindablePropertyDeprecatedSpec()
        }

        it("should support a custom value transform") {
            var backingVariable = ""
            let binding = BindableProperty<BindablePropertyDeprecatedSpec, String>(subject) { _, value in backingVariable = value }

            let currentValueSubscribable = CurrentValueSubscribable(11)
            binding.bind(currentValueSubscribable, transform: { intValue in "\(intValue)" })
            
            expect(backingVariable) == "11"
        }
        
        it("should support binding to a block (\"anonymous Computed\")") {
            var backingVariable = ""
            let binding = BindableProperty<BindablePropertyDeprecatedSpec, String>(subject) { _, value in backingVariable = value }

            let name = CurrentValueSubscribable("")
            binding.bind { "Hello, \(name.value)!" }
            name.value = "world"

            expect(backingVariable).toEventually(equal("Hello, world!"))
        }
    }
}
