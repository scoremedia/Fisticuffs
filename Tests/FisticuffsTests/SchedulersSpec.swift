//  The MIT License (MIT)
//
//  Copyright (c) 2021 theScore Inc.
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

class SchedulersSpec: QuickSpec {
    override func spec() {
        describe("DispatchQueue Scheduler") {
            it("should perform action in the given queue") {
                let expectation = self.expectation(description: "wait")

                let backgroundThread = DispatchQueue(label: "background thread")

                let subject = DispatchQueue.main

                backgroundThread.async {
                    subject.schedule {
                        expect(Thread.isMainThread).to(beTrue())
                        expectation.fulfill()
                    }
                }

                self.wait(for: [expectation], timeout: 5)
            }
        }

        describe("RunLoop Scheduler") {
            it("should perform action") {
                let expectation = self.expectation(description: "wait")

                let backgroundThread = DispatchQueue(label: "background thread")

                let subject = RunLoop.main

                backgroundThread.async {
                    subject.schedule {
                        expect(Thread.isMainThread).to(beTrue())
                        expectation.fulfill()
                    }
                }

                self.wait(for: [expectation], timeout: 5)
            }
        }

        describe("OperationQueue Scheduler") {
            it("should perform action") {
                let expectation = self.expectation(description: "wait")

                let backgroundThread = DispatchQueue(label: "background thread")

                let subject = OperationQueue.main

                backgroundThread.async {
                    subject.schedule {
                        expect(Thread.isMainThread).to(beTrue())
                        expectation.fulfill()
                    }
                }

                self.wait(for: [expectation], timeout: 5)
            }
        }

        describe("MainThreadScheduler") {
            var subject: MainThreadScheduler!

            beforeEach {
                subject = MainThreadScheduler()
            }

            it("should perform action on main thread") {
                let expectation = self.expectation(description: "wait")

                let backgroundThread = DispatchQueue(label: "background thread")

                backgroundThread.async {
                    subject.schedule {
                        expect(Thread.isMainThread).to(beTrue())
                        expectation.fulfill()
                    }
                }

                self.wait(for: [expectation], timeout: 5)
            }

            it("should perform action immediately if current thread is main") {
                let expectation = self.expectation(description: "scheduler")
                let expectation2 = self.expectation(description: "main")

                var numbers = [Int]()

                DispatchQueue.main.async {
                    subject.schedule {
                        numbers.append(1)
                        expectation.fulfill()
                    }

                    numbers.append(2)
                    expectation2.fulfill()
                }

                self.wait(for: [expectation, expectation2], timeout: 5)
                
                expect(numbers) == [1,2]
            }
        }
    }
}
