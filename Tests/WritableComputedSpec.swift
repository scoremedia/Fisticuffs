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
                            let nameStartIndex = value.index(value.startIndex, offsetBy: "Hello, ".characters.count)
                            name.value = value.substring(from: nameStartIndex)
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
                expect(sum.value).toEventually(equal(84))
            }

            context("coalescing updates") {
                it("should coalesce updates") {
                    var numberOfTimesComputed = 0

                    let a = Observable(11)
                    let b = Observable(42)

                    let sum: WritableComputed<Int> = WritableComputed(
                        getter: {
                            numberOfTimesComputed += 1
                            return a.value + b.value
                        },
                        setter: { _ in }
                    )

                    a.value = 2
                    b.value = 3

                    expect(sum.value).toEventually(equal(5))

                    // once for init() & once for updating a/b
                    expect(numberOfTimesComputed) == 2
                }

                it("should immediately recompute if `.value` is accessed & it is dirty") {
                    let a = Observable(5)
                    let result = WritableComputed(
                        getter: { a.value },
                        setter: { _ in }
                    )

                    a.value = 11
                    expect(result.value) == 11
                }

                it("should avoid sending multiple updates when recomputed early due to accessing `value`") {
                    let a = Observable(5)
                    let result = WritableComputed(
                        getter: { a.value },
                        setter: { _ in }
                    )

                    var notificationCount = 0
                    let opts = SubscriptionOptions(notifyOnSubscription: false, when: .afterChange)
                    _ = result.subscribe(opts) { notificationCount += 1 }

                    a.value = 11
                    expect(result.value) == 11

                    // let runloop finish so that coalesced update happens
                    RunLoop.main.run(until: Date())

                    expect(notificationCount) == 1
                }

                it("should not recurse infinitely if the value is accessed in the subscription block") {
                    let a = Observable(5)
                    let result = WritableComputed(
                        getter: { a.value },
                        setter: { _ in }
                    )
                    
                    _ = result.subscribe { [weak result] in
                        _ = result?.value // trigger "side effects" in getter
                    }
                    a.value = 11
                    expect(result.value) == 11
                    // this test will blow the stack here if it fails
                }
            }

            it("should not collect dependencies for any Subscribables read in its subscriptions") {
                let shouldNotDependOn = Observable(false)

                let a = Observable(11)

                let computed = WritableComputed(getter: { a.value }, setter: { _ in })
                // attempt to introduce a (false) dependency on `shouldNotDependOn`
                _ = computed.subscribe { _, _ in
                    _ = shouldNotDependOn.value // trigger "side effects" in getter
                }
                a.value = 5 // trigger the subscription block

                var fired = false
                _ = computed.subscribe(SubscriptionOptions(notifyOnSubscription: false, when: .afterChange)) { _, _ in fired = true }

                // if a dependency was added, this'll cause `fired` to be set to `true`
                shouldNotDependOn.value = true

                expect(fired) == false
            }
        }
    }
}
