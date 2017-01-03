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
            it("should push changes to the observable after a delay") {
                let observable = Observable("")

                property.bind(observable, BindingHandlers.throttle(delayBy: .milliseconds(500)))

                backingVariable = "1"
                property.pushChangeToObservable()

                expect(observable.value) == ""
                expect(observable.value).toEventually(equal("1"), timeout: 1.0)
            }

            it("should push the most recent value to the observable after a delay") {
                let observable = Observable("")

                property.bind(observable, BindingHandlers.throttle(delayBy: .milliseconds(500)))

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

                property.bind(observable, BindingHandlers.throttle(delayBy: .milliseconds(100)))
                backingVariable = "test"
                property.pushChangeToObservable()

                waitUntil(timeout: 1.0) { done in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: done)
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

                property.bind(observable, ThrottleBindingHandler(delayBy: .milliseconds(500), bindingHandler: toIntBindingHandler))

                backingVariable = "50"
                property.pushChangeToObservable()

                expect(observable.value).toEventually(equal(Optional.some(50)), timeout: 1.0)
            }

            it("should update control value immediately when observable value changes") {
                let observable = Observable("")

                property.bind(observable, BindingHandlers.throttle(delayBy: .seconds(1)))
                observable.value = "test"

                expect(backingVariable) == observable.value
            }

            it("should support computed subscribable") {
                let observable = Observable("")

                let computed: Computed<String> = Computed {
                    observable.value.uppercased()
                }

                property.bind(observable, BindingHandlers.throttle(delayBy: .milliseconds(500)))

                backingVariable = "hello"
                property.pushChangeToObservable()

                expect(computed.value).toEventually(equal(backingVariable.uppercased()), timeout: 1.0)
            }

            it("should support optionals") {
                var optionalBackingVariable: String?

                let optionalProperty: BidirectionalBindableProperty<BindingHandlersSpec, String?> = BidirectionalBindableProperty(
                    control: self,
                    getter: {_ in optionalBackingVariable},
                    setter: { (_, value) in optionalBackingVariable = value}
                )

                let observable = Observable("")

                optionalProperty.bind(observable, BindingHandlers.throttle(delayBy: .milliseconds(500)))

                optionalBackingVariable = "test"
                optionalProperty.pushChangeToObservable()

                expect(observable.value) == ""
                expect(observable.value).toEventually(equal(optionalBackingVariable), timeout: 1.0)
            }
        }
    }
}

