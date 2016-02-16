//
//  BindingHandlersSpec.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-16.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Fisticuffs


class BindingHandlersSpec: QuickSpec {
    override func spec() {
        var backingVariable = ""
        var property: BidirectionalBindableProperty<BindingHandlersSpec, String>!

        beforeEach {
            property = BidirectionalBindableProperty(
                control: self,
                getter: { _ in backingVariable },
                setter: { _, value in backingVariable = value }
            )
        }

        describe("TransformBindingHandler") {
            it("should support transforming values to the desired property type") {
                let observable = Observable(0)
                property.bind(observable, BindingHandlers.transform { input in "\(input)" })
                observable.value = 11
                expect(backingVariable) == "11"
            }

            it("should support transforming the property type back to the data type") {
                let observable = Observable(0)
                property.bind(observable, BindingHandlers.transform({ input in "\(input)" }, reverse: { str in Int(str) ?? 0 }))

                backingVariable = "42"
                property.pushChangeToObservable()

                expect(observable.value) == 42
            }
        }

    }
}

