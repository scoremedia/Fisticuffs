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


class WritableComputedSpec: QuickSpec {
    override func spec() {
        describe("WritableComputed") {
            it("should call its setter when a value is set") {
                let name = Observable("John")
                let greeting = WritableComputed(
                    getter: { "Hello, " + name.value },
                    setter: { value in
                        if value.hasPrefix("Hello, ") {
                            let nameStartIndex = value.startIndex.advancedBy("Hello, ".characters.count)
                            name.value = value.substringFromIndex(nameStartIndex)
                        } else {
                            name.value = ""
                        }
                    }
                )

                expect(greeting.value) == "Hello, John"

                // update `name` by modifying `greeting`
                greeting.value = "Hello, Bob"
                expect(name.value) == "Bob"
            }

            it("should derive its value from the provided block, regardless of what it is set to") {
                let a = Observable(11)
                let b = Observable(42)
                
                let sum = WritableComputed(
                    getter: { a.value + b.value },
                    setter: { _ in }
                )

                sum.value = 5
                expect(sum.value) == 53
            }
            
            it("should update its value when any dependencies change") {
                let a = Observable(11)
                let b = Observable(42)
                
                let sum = WritableComputed(
                    getter: { a.value + b.value },
                    setter: { _ in }
                )
                
                a.value = 42
                expect(sum.value) == 84
            }

            it("should not collect dependencies for any Subscribables read in its subscriptions") {
                let shouldNotDependOn = Observable(false)

                let a = Observable(11)

                let computed = WritableComputed(getter: { a.value }, setter: { _ in })
                // attempt to introduce a (false) dependency on `shouldNotDependOn`
                computed.subscribe { _, _ in
                    shouldNotDependOn.value
                }
                a.value = 5 // trigger the subscription block

                var fired = false
                computed.subscribe(SubscriptionOptions(notifyOnSubscription: false, when: .AfterChange)) { _, _ in fired = true }

                // if a dependency was added, this'll cause `fired` to be set to `true`
                shouldNotDependOn.value = true

                expect(fired) == false
            }
        }
    }
}
