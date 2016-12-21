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

        describe("ThrottleBindingHandler") {
            it("should push changes to the observable after a timeout") {
                let observable = Observable("")

                property.bind(observable, BindingHandlers.defaultThrottle(delayInSeconds: 1))

                backingVariable = "1"
                property.pushChangeToObservable()

                expect(observable.value) == ""
                expect(observable.value).toEventually(equal("1"), timeout: 3.0)
            }

            it("should push the most recent value to the observable after a timeout") {
                let observable = Observable("")

                property.bind(observable, BindingHandlers.defaultThrottle(delayInSeconds: 1))

                var numberOfTimesObservableIsNotified = 0
                var publishedValues = [String]()

                let options = SubscriptionOptions(notifyOnSubscription: false, when: .afterChange)

                _ = observable.subscribe(options) { _, newValue in
                    numberOfTimesObservableIsNotified += 1
                    publishedValues.append(newValue)
                }

                for i in 1...10 {
                    backingVariable = "\(i)"
                    property.pushChangeToObservable()
                }

                expect(numberOfTimesObservableIsNotified).toEventually(equal(1), timeout: 2.0)
                expect(publishedValues).toEventually(equal(["10"]), timeout: 2.0)
            }

            it("should push a value to the observable exactly once") {
                let observable = Observable("")
                var numberOfTimesObservableIsNotified = 0

                let options = SubscriptionOptions(notifyOnSubscription: false, when: .afterChange)

                _ = observable.subscribe(options) { _, newValue in
                    numberOfTimesObservableIsNotified += 1
                }

                property.bind(observable, BindingHandlers.defaultThrottle(delayInSeconds: 1))
                backingVariable = "test"
                property.pushChangeToObservable()

                waitUntil(timeout: 4.0) { done in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3), execute: done)
                }

                expect(numberOfTimesObservableIsNotified) == 1
            }

            it("should transform the value") {
                let observable: Observable<Int?> = Observable(nil)
                let toIntBindingHandler: BindingHandler<BindingHandlersSpec, Int?, String> = BindingHandlers.transform(
                    { data in
                        if let data = data { return String(data) }
                        return ""
                    },
                    reverse: { Int($0) }
                )

                property.bind(observable, ThrottleBindingHandler(seconds: 1, bindingHandler: toIntBindingHandler))

                backingVariable = "50"
                property.pushChangeToObservable()

                expect(observable.value).toEventually(equal(Optional.some(50)), timeout: 3.0)
            }

            it("should update control value immediately when observable value changes") {
                let observable = Observable("")

                property.bind(observable, BindingHandlers.defaultThrottle(delayInSeconds: 2))
                observable.value = "test"

                expect(backingVariable) == observable.value
            }
        }
    }
}

