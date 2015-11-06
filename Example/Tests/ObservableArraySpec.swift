//
//  ObservableArraySpec.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-15.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


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
            
            let disposable = array.subscribe(options) { items in
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
                case let .Set(elements):
                    receivedInitial = true
                    expect(elements) == [1, 2, 3]
                
                case let .Insert(index, newElements):
                    receivedInsert = true
                    expect(index) == 3
                    expect(newElements) == [4]
                    
                case let .Remove(range, removedElements):
                    receivedRemove = true
                    expect(range) == Range(start: 1, end: 3)
                    expect(removedElements) == [2, 3]
                    
                case let .Replace(range, removedElements, newElements):
                    receivedReplace = true
                    expect(range) == Range(start: 0, end: 1)
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
            
            array.value.removeRange(1..<3)
            expect(receivedRemove) == true
            
            array.value.replaceRange(0..<1, with: [6, 5])
            expect(receivedReplace) == true
        }
        
        it("should notify subscribers when the underlying value is set") {
            var array = Observable([1, 2, 3])
            
            var receivedSet = false
            
            let options = SubscriptionOptions(notifyOnSubscription: false, when: .AfterChange)
            let disposable = array.subscribeArray(options) { newValue, change in
                switch change {
                case let .Set(elements):
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
                case let .Replace(range, removedElements, newElements):
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
