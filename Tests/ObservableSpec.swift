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


class ObservableSpec: QuickSpec {
    override func spec() {
        
        it("should store values") {
            let observable = Observable("test")
            expect(observable.value) == "test"
            
            observable.value = "test 2"
            expect(observable.value) == "test 2"
        }
        
        it("should notify observers when its value changes") {
            let observable = Observable(5)
            var receivedValue = 0
            
            let disposable = observable.subscribe { _, newValue in receivedValue = newValue }
            defer {
                disposable.dispose()
            }
            
            observable.value = 11
            expect(receivedValue) == 11
        }
        
        it("should remove observers via the returned Disposable") {
            let observable = Observable(true)
            var receivedValue = true
            
            let disposable = observable.subscribe { _, newValue in receivedValue = newValue }
            disposable.dispose()
            
            observable.value = false
            
            // value won't have changed if the .dispose() call worked
            expect(receivedValue) == true
        }
        
        it("should obey the notifyOnSubscription option") {
            let observable = Observable(11)
            
            do {
                var receivedValue = false
                
                // default is notifyOnSubscription = true, so we should receive a value
                observable.subscribe {
                    receivedValue = true
                }.dispose()
                
                expect(receivedValue) == true
            }
            
            do {
                var receivedValue = false
                
                var dontNotifyOnSubscription = SubscriptionOptions()
                dontNotifyOnSubscription.notifyOnSubscription = false
                
                observable.subscribe(dontNotifyOnSubscription) {
                    receivedValue = true
                }.dispose()
                
                expect(receivedValue) == false
            }
        }
        
        it("should support receiving before-change callbacks") {
            var options = SubscriptionOptions()
            options.notifyOnSubscription = false
            options.when = .BeforeChange
            
            var receivedBeforeChange = false
            
            let observable = Observable(3.14)
            
            let disposable = observable.subscribe(options) { _, newValue in
                if observable.value != newValue {
                    receivedBeforeChange = true
                }
            }
            
            observable.value = 11.0
            disposable.dispose()
            
            expect(receivedBeforeChange) == true
        }
        
    }
}
