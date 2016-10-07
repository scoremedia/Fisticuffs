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


class MemoryManagementSpec: QuickSpec {
    override func spec() {
        
        describe("Observable") {
            it("should not be referenced strongly by its subscriptions") {
                weak var weakObservable: Observable<String>?
                
                autoreleasepool {
                    let observable: Observable<String>? = Observable("test")
                    weakObservable = observable
                    _ = observable?.subscribe { }
                    
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
                    _ = computed?.subscribe { }
                    
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
                    _ = button.b_onTap.subscribe(viewModel.noop)
                }
                
                // if button correctly disposes of the tap listener, view model should be dealloc'd
                expect(weakViewModel).to(beNil())
            }
        }
    }
}
