//
//  MemoryManagementSpec.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-14.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


class MemoryManagementSpec: QuickSpec {
    override func spec() {
        
        describe("Observable") {
            it("should not be referenced strongly by its subscriptions") {
                weak var weakObservable: Observable<String>?
                
                autoreleasepool {
                    let observable: Observable<String>? = Observable("test")
                    weakObservable = observable
                    observable?.subscribe { }
                    
                    // observable should dealloc here
                }
                
                expect(weakObservable).to(beNil())
            }
        }
        
        describe("Computed") {
            it("should not be referenced strongly by its subscriptions") {
                weak var weakComputed: Computed<String>?
                
                autoreleasepool {
                    let computed: Computed<String>? = Computed { "Hello" }
                    weakComputed = computed
                    computed?.subscribe { }
                    
                    // computed should dealloc here
                }
                
                expect(weakComputed).to(beNil())
            }
        }
        
        describe("UIKit") {
            it("should dispose of any subscriptions on dealloc") {
                weak var weakObservable: Observable<String>?
                
                autoreleasepool {
                    let observable = Observable("testing memory management")
                    weakObservable = observable
                    
                    let textField = UITextField()
                    textField.b_text.bind(observable)
                }
                
                // if textField properly disposed of it's subscriptions, the object weakObservable
                // is pointing at will have been dealloc'd
                expect(weakObservable).to(beNil())
            }
            
            it("should release any actions on dealloc") {
                class NoopViewModel {
                    func noop() { }
                }
                
                weak var weakViewModel: NoopViewModel?
                
                autoreleasepool {
                    let viewModel = NoopViewModel()
                    weakViewModel = viewModel
                    
                    let button = UIButton()
                    button.b_onTap.subscribe(viewModel.noop)
                }
                
                // if button correctly disposes of the tap listener, view model should be dealloc'd
                expect(weakViewModel).to(beNil())
            }
        }
    }
}
