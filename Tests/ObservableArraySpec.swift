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


class ObservableArraySpec: QuickSpec {
    override func spec() {
        
        it("should behave like an array") {
            var array = Observable(["Hello", "World"])
            expect(array.value.count) == 2
            expect(array.value[0]) == "Hello"
            expect(array.value[1]) == "World"
            
            expect(array.value[0..<2]).to(contain("Hello", "World"))
            
            array.value[1] = "Fred"
            expect(array.value[1]) == "Fred"
            
            array.value.removeLast()
            expect(array.value.count) == 1
            expect(array.value.first) == "Hello"
            
            array.value.append("World")
        }
        
        it("should notify subscribers when its value changes") {
            var array = Observable([1, 2, 3])
            
            var receivedValue = false
            
            var options = SubscriptionOptions()
            options.notifyOnSubscription = false
            
            let disposable = array.subscribe(options) { _, items in
                receivedValue = true
            }
            defer {
                disposable.dispose()
            }
            
            array.value.append(4)
            
            expect(receivedValue) == true
        }
        
        it("should notify subscribers with the specifics of each change") {
            var array = Observable([1, 2, 3])
            
            var receivedInitial = false
            var receivedInsert = false
            var receivedRemove = false
            var receivedReplace = false
            
            let disposable = array.subscribeArray { newValue, change in
                switch change {
                case let .set(elements):
                    receivedInitial = true
                    expect(elements) == [1, 2, 3]
                
                case let .insert(index, newElements):
                    receivedInsert = true
                    expect(index) == 3
                    expect(newElements) == [4]
                    
                case let .remove(range, removedElements):
                    receivedRemove = true
                    expect(range) == 1..<3
                    expect(removedElements) == [2, 3]
                    
                case let .replace(range, removedElements, newElements):
                    receivedReplace = true
                    expect(range) == 0..<1
                    expect(removedElements) == [1]
                    expect(newElements) == [6, 5]
                }
            }
            defer {
                disposable.dispose()
            }
            
            expect(receivedInitial) == true
            
            array.value.append(4)
            expect(receivedInsert) == true
            
            array.value.removeSubrange(1..<3)
            expect(receivedRemove) == true
            
            array.value.replaceSubrange(0..<1, with: [6, 5])
            expect(receivedReplace) == true
        }
        
        it("should notify subscribers when the underlying value is set") {
            var array = Observable([1, 2, 3])
            
            var receivedSet = false
            
            let options = SubscriptionOptions(notifyOnSubscription: false, when: .afterChange)
            let disposable = array.subscribeArray(options) { newValue, change in
                switch change {
                case let .set(elements):
                    receivedSet = true
                    expect(elements) == [4, 5]
                    
                default:
                    break
                }
            }
            defer {
                disposable.dispose()
            }
            
            array.value = [4, 5]
            expect(receivedSet) == true
        }
        
        it("should notify subscribers when elements are replaced via subscript") {
            var array = Observable([1, 2, 3])
            
            var receivedReplace = false
            
            let disposable = array.subscribeArray { newValue, change in
                switch change {
                case let .replace(range, removedElements, newElements):
                    receivedReplace = true
                    expect(range) == 0..<1
                    expect(removedElements) == [1]
                    expect(newElements) == [11]
                    
                default:
                    break
                }
            }
            defer {
                disposable.dispose()
            }
            
            array.value[0] = 11
            expect(receivedReplace) == true
        }
    }
}
