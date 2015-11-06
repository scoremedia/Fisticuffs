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
            it("should stay alive until the last observer has been disposed") {
                weak var weakObservable: Observable<String>?
                
                autoreleasepool {
                    var observable: Observable<String>? = Observable("test")
                    weakObservable = observable
                    
                    let disposable = observable!.subscribe { (_: String) in }
                    observable = nil
                    
                    // still have 1 observer
                    expect(weakObservable).toNot(beNil())
                    
                    disposable.dispose()
                    // should be dealloc'd now (observer was removed)
                }
                
                expect(weakObservable).to(beNil())
            }
        }
        
        describe("Computed") {
            it("should dispose of its dependencies on deinit") {
                weak var weakComputed: Computed<Bool>?
                weak var weakDependency: Observable<Bool>?
                
                autoreleasepool {
                    var dependency: Observable<Bool>? = Observable(true)
                    var computed: Computed<Bool>? = Computed<Bool> {
                        !dependency!.value
                    }
                    
                    let disposable = computed!.subscribe { value in }
                    
                    weakComputed = computed
                    weakDependency = dependency
                    
                    autoreleasepool {
                        dependency = nil
                        computed = nil
                    }
                    
                    // still have an observer
                    expect(weakComputed).toNot(beNil())
                    expect(weakDependency).toNot(beNil())
                    
                    disposable.dispose()
                    // should dealloc now (no more observers)
                }
                
                expect(weakComputed).to(beNil())
                expect(weakDependency).to(beNil())
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
                    button.b_onTap(viewModel.noop)
                }
                
                // if button correctly disposes of the tap listener, view model should be dealloc'd
                expect(weakViewModel).to(beNil())
            }
        }
    }
}
