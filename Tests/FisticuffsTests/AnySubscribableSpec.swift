//  The MIT License (MIT)
//
//  Copyright (c) 2018 theScore Inc.
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


class AnySubscribableSpec: QuickSpec {
    override func spec() {
        describe("AnySubscribableBox") {
            it("should use the identity of the boxed AnySubscribable for Equatable") {
                let observable: Observable<String> = Observable("test")
                let computed: Computed<Int> = Computed { return 11 }

                let observableBoxed1 = AnySubscribableBox(subscribable: observable)
                let observableBoxed2 = AnySubscribableBox(subscribable: observable)
                let computedBoxed1 = AnySubscribableBox(subscribable: computed)
                let computedBoxed2 = AnySubscribableBox(subscribable: computed)

                expect(observableBoxed1) == observableBoxed2
                expect(computedBoxed1) == computedBoxed2

                expect(observableBoxed1) != computedBoxed2
            }

            it("should implement Hashable") {
                let observable: Observable<String> = Observable("test")
                let observableBoxed1 = AnySubscribableBox(subscribable: observable)
                let observableBoxed2 = AnySubscribableBox(subscribable: observable)

                expect(observableBoxed1.hashValue) == observableBoxed2.hashValue
            }
        }
    }
}
