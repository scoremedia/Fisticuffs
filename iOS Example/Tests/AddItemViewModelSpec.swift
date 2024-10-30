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

import Quick
import Nimble
import Fisticuffs
@testable import iOS_Example


class AddItemViewModelSpec: QuickSpec {
    
    override class func spec() {
        describe("AddItemViewModel") {
            var viewModel = AddItemViewModel()
            var finishedResult: AddItemResult?
            
            beforeEach {
                viewModel = AddItemViewModel()
                viewModel.finished += { _, result in finishedResult = result }
            }
            
            
            it("should finish with a cancel result if Cancel is tapped") {
                viewModel.cancelTapped()
                guard case .some(.Cancelled) = finishedResult else { fail(); return }
            }
            
            it("should finish with a new item result if Done is tapped and input is valid") {
                viewModel.item.title.value = "Hello"
                viewModel.doneTapped()
                
                guard case .some(.NewToDoItem(let item)) = finishedResult, item.title.value == "Hello" else { fail(); return }
            }
            
            it("should require a non-empty title to be valid") {
                viewModel.item.title.value = ""
                expect(viewModel.inputIsValid.value) == false
                
                viewModel.item.title.value = "Testing"
                expect(viewModel.inputIsValid.value) == true
            }
        }
    }
    
}
