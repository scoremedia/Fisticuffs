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
            var array = ObservableArray(["Hello", "World"])
            expect(array.count) == 2
            expect(array[0]) == "Hello"
            expect(array[1]) == "World"
            
            expect(array[0..<2]).to(contain("Hello", "World"))
            
            array[1] = "Fred"
            expect(array[1]) == "Fred"
            
            array.removeLast()
            expect(array.count) == 1
            expect(array.first) == "Hello"
            
            array.append("World")
        }
        
        it("should notify subscribers when its value changes") {
            var array = ObservableArray([1, 2, 3])
            
            var receivedValue = false
            
            var options = SubscriptionOptions()
            options.notifyOnSubscription = false
            
            let disposable = array.subscribe(options) { items in
                receivedValue = true
            }
            defer {
                disposable.dispose()
            }
            
            array.append(4)
            
            expect(receivedValue) == true
        }
        
        it("should notify subscribers with the specifics of each change") {
            var array = ObservableArray([1, 2, 3])
            
            var receivedInitial = false
            var receivedInsert = false
            var receivedRemove = false
            var receivedReplace = false
            
            let disposable = array.subscribeArray { newValue, change in
                switch change {
                case let .Initial(elements):
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
            
            array.append(4)
            expect(receivedInsert) == true
            
            array.removeRange(1..<3)
            expect(receivedRemove) == true
            
            array.replaceRange(0..<1, with: [6, 5])
            expect(receivedReplace) == true
            
        }
        
    }
}
