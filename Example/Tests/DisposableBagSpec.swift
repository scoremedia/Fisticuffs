//
//  DisposableBagSpec.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


class DisposableBagSpec: QuickSpec {
    override func spec() {
        
        it("should dispose of its disposables on dealloc") {
            
            // should remain false if DisposableBag disposes of the subscription below
            var receivedValue = false
            
            let observable = Observable("test")
            
            autoreleasepool {
                let bag = DisposableBag()
                
                var options = SubscriptionOptions()
                options.notifyOnSubscription = false
                
                observable.subscribe(options) { _ in
                    receivedValue = true
                }
                .addTo(bag)
            }
            
            // if DisposableBag worked, our subscription setting receivedValue=true should be gone
            // by now
            
            observable.value = "test completed"
            
            expect(receivedValue) == false
        }
        
    }
}
