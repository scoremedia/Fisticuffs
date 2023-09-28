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
                let currentValueSubscribable = CurrentValueSubscribable(0)
                property.bind(currentValueSubscribable, BindingHandlers.transform { input in "\(input)" })
                currentValueSubscribable.value = 11
                expect(backingVariable) == "11"
            }

            it("should support transforming the property type back to the data type") {
                let currentValueSubscribable = CurrentValueSubscribable(0)
                property.bind(currentValueSubscribable, BindingHandlers.transform({ input in "\(input)" }, reverse: { str in Int(str) ?? 0 }))

                backingVariable = "42"
                property.pushChangeToCurrentValueSubscribable()

                expect(currentValueSubscribable.value) == 42
            }
        }

        describe("ThrottleBindingHandler") {
            it("should push changes to the currentValueSubscribable after a delay") {
                let currentValueSubscribable = CurrentValueSubscribable("")

                property.bind(currentValueSubscribable, BindingHandlers.throttle(delayBy: .milliseconds(500)))

                backingVariable = "1"
                property.pushChangeToCurrentValueSubscribable()

                expect(currentValueSubscribable.value) == ""
                expect(currentValueSubscribable.value).toEventually(equal("1"), timeout: .seconds(1))
            }

            it("should push the most recent value to the currentValueSubscribable after a delay") {
                let currentValueSubscribable = CurrentValueSubscribable("")

                property.bind(currentValueSubscribable, BindingHandlers.throttle(delayBy: .milliseconds(500)))

                var numberOfTimesCurrentValueSubscribableIsNotified = 0
                var publishedValues = [String]()

                let options = SubscriptionOptions(notifyOnSubscription: false, when: .afterChange)

                _ = currentValueSubscribable.subscribe(options) { _, newValue in
                    numberOfTimesCurrentValueSubscribableIsNotified += 1
                    publishedValues.append(newValue)
                }

                for i in 1...10 {
                    backingVariable = "\(i)"
                    property.pushChangeToCurrentValueSubscribable()
                }

                expect(numberOfTimesCurrentValueSubscribableIsNotified).toEventually(equal(1), timeout: .seconds(2))
                expect(publishedValues).toEventually(equal(["10"]), timeout: .seconds(2))
            }

            it("should push a value to the currentValueSubscribable exactly once") {
                let currentValueSubscribable = CurrentValueSubscribable("")
                var numberOfTimesCurrentValueSubscribableIsNotified = 0

                let options = SubscriptionOptions(notifyOnSubscription: false, when: .afterChange)

                _ = currentValueSubscribable.subscribe(options) { _, newValue in
                    numberOfTimesCurrentValueSubscribableIsNotified += 1
                }

                property.bind(currentValueSubscribable, BindingHandlers.throttle(delayBy: .milliseconds(100)))
                backingVariable = "test"
                property.pushChangeToCurrentValueSubscribable()

                waitUntil(timeout: .seconds(1)) { done in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: done)
                }

                expect(numberOfTimesCurrentValueSubscribableIsNotified) == 1
            }

            it("should transform the value") {
                let currentValueSubscribable: CurrentValueSubscribable<Int?> = CurrentValueSubscribable(nil)
                let toIntBindingHandler: BindingHandler<BindingHandlersSpec, Int?, String> = BindingHandlers.transform(
                    { data in
                        if let data = data { return String(data) }
                        return ""
                    },
                    reverse: { Int($0) }
                )

                property.bind(currentValueSubscribable, ThrottleBindingHandler(delayBy: .milliseconds(500), bindingHandler: toIntBindingHandler))

                backingVariable = "50"
                property.pushChangeToCurrentValueSubscribable()

                expect(currentValueSubscribable.value).toEventually(equal(Optional.some(50)), timeout: .seconds(1))
            }

            it("should update control value immediately when currentValueSubscribable value changes") {
                let currentValueSubscribable = CurrentValueSubscribable("")

                property.bind(currentValueSubscribable, BindingHandlers.throttle(delayBy: .seconds(1)))
                currentValueSubscribable.value = "test"

                expect(backingVariable) == currentValueSubscribable.value
            }

            it("should support computed subscribable") {
                let currentValueSubscribable = CurrentValueSubscribable("")

                let computed: Computed<String> = Computed {
                    currentValueSubscribable.value.uppercased()
                }

                property.bind(currentValueSubscribable, BindingHandlers.throttle(delayBy: .milliseconds(500)))

                backingVariable = "hello"
                property.pushChangeToCurrentValueSubscribable()

                expect(computed.value).toEventually(equal(backingVariable.uppercased()), timeout: .seconds(1))
            }

            it("should support optionals") {
                var optionalBackingVariable: String?

                let optionalProperty: BidirectionalBindableProperty<BindingHandlersSpec, String?> = BidirectionalBindableProperty(
                    control: self,
                    getter: {_ in optionalBackingVariable},
                    setter: { (_, value) in optionalBackingVariable = value}
                )

                let currentValueSubscribable = CurrentValueSubscribable("")

                optionalProperty.bind(currentValueSubscribable, BindingHandlers.throttle(delayBy: .milliseconds(500)))

                optionalBackingVariable = "test"
                optionalProperty.pushChangeToCurrentValueSubscribable()

                expect(currentValueSubscribable.value) == ""
                expect(currentValueSubscribable.value).toEventually(equal(optionalBackingVariable), timeout: .seconds(1))
            }
        }
    }
}

