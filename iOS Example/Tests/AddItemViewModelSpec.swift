//
//  AddItemViewModelSpec.swift
//  iOS Example
//
//  Created by Darren Clark on 2015-11-17.
//  Copyright © 2015 theScore. All rights reserved.
//

import Quick
import Nimble
import SwiftMVVMBinding
@testable import iOS_Example


class AddItemViewModelSpec: QuickSpec {
    
    override func spec() {
        describe("AddItemViewModel") {
            var viewModel = AddItemViewModel()
            var finishedResult: AddItemResult?
            
            beforeEach {
                viewModel = AddItemViewModel()
                viewModel.finished += { _, result in finishedResult = result }
            }
            
            
            it("should finish with a cancel result if Cancel is tapped") {
                viewModel.cancelTapped()
                guard case .Some(.Cancelled) = finishedResult else { fail(); return }
            }
            
            it("should finish with a new item result if Done is tapped and input is valid") {
                viewModel.item.title.value = "Hello"
                viewModel.doneTapped()
                
                guard case .Some(.NewToDoItem(let item)) = finishedResult
                    where item.title.value == "Hello" else { fail(); return }
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
