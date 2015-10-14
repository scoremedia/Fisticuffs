//
//  ObservableSpec.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


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
            
            observable.subscribe { newValue in receivedValue = newValue }
            
            observable.value = 11
            expect(receivedValue) == 11
        }
        
        it("should remove observers via the returned Disposable") {
            let observable = Observable(true)
            var receivedValue = true
            
            let disposable = observable.subscribe { newValue in receivedValue = newValue }
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
                observable.subscribe { _ in
                    receivedValue = true
                }.dispose()
                
                expect(receivedValue) == true
            }
            
            do {
                var receivedValue = false
                
                var dontNotifyOnSubscription = SubscriptionOptions()
                dontNotifyOnSubscription.notifyOnSubscription = false
                
                observable.subscribe(dontNotifyOnSubscription) { _ in
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
            
            let disposable = observable.subscribe(options) { newValue in
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
