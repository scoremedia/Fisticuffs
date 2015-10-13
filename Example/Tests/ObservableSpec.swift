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
@testable import Bindings


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
            
            observable.addObserver { newValue in receivedValue = newValue }
            
            observable.value = 11
            expect(receivedValue) == 11
        }
        
        it("should remove observers via the returned Disposable") {
            let observable = Observable(true)
            var receivedValue = true
            
            let disposable = observable.addObserver { newValue in receivedValue = newValue }
            disposable.dispose()
            
            observable.value = false
            
            // value won't have changed if the .dispose() call worked
            expect(receivedValue) == true
        }
        
    }
}
