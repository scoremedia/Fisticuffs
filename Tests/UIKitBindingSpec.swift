//
//  UIKitBindingSpec.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


class UIKitBindingSpec: QuickSpec {
    override func spec() {
        
        describe("UILabel") {
            it("should support binding it's text value") {
                let name = Observable("")
                
                let label = UILabel()
                label.b_text.bind(name)
                
                name.value = "Fred"
                expect(label.text) == "Fred"
            }
        }
        
        describe("UIControl") {
            it("should support binding it's enabled value") {
                let enabled = Observable(false)
                
                let control = UIControl()
                control.b_enabled.bind(enabled)
                expect(control.enabled) == false
                
                enabled.value = true
                expect(control.enabled) == true
            }
            
            it("should allow subscribing to arbitrary control events") {
                var receivedEvent = false
                
                let control = UIControl()
                control.b_controlEvent(.AllEvents) += { receivedEvent = true }
                
                control.sendActionsForControlEvents(.EditingDidBegin)
                expect(receivedEvent) == true
            }
        }
        
        describe("UIButton") {
            it("should support binding an action for when the user taps") {
                var receivedTap = false
                
                let button = UIButton()
                button.b_onTap.subscribe { receivedTap = true }
                
                button.sendActionsForControlEvents(.TouchUpInside)
                
                expect(receivedTap) == true
            }
        }
        
        describe("UIDatePicker") {
            it("should support 2 way binding on its text value") {
                
                let initial = NSDate()
                
                let value = Observable(initial)
                let datePicker = UIDatePicker()
                datePicker.b_date.bind(value)
                
                expect(datePicker.date) == initial
                
                // pretend the user goes to the next day
                let tomorrow = initial.dateByAddingTimeInterval(24 * 60 * 60)
                datePicker.date = tomorrow
                datePicker.sendActionsForControlEvents(.ValueChanged)
                
                expect(datePicker.date) == tomorrow
                expect(value.value) == tomorrow
                
                // modify it programmatically
                let yesterday = initial.dateByAddingTimeInterval(-24 * 60 * 60)
                value.value = yesterday
                
                expect(datePicker.date) == yesterday
                expect(value.value) == yesterday
            }
        }
        
        describe("UITextField") {
            it("should support 2 way binding on its text value") {
                
                let value = Observable("Hello")
                let textField = UITextField()
                textField.b_text.bind(value)
                
                expect(textField.text) == "Hello"
                
                // pretend the user types " world"
                textField.text = (textField.text ?? "") + " world"
                textField.sendActionsForControlEvents(.EditingChanged)
                
                expect(textField.text) == "Hello world"
                expect(value.value) == "Hello world"
                
                // modify it programmatically
                value.value = "Bye"
                
                expect(textField.text) == "Bye"
                expect(value.value) == "Bye"
            }
        }
        
        describe("UIBarButtonItem") {
            let barButtonItem = UIBarButtonItem()
            
            it("should support taps") {
                var receivedAction = false
                let disposable = barButtonItem.b_onTap.subscribe { receivedAction = true }
                defer { disposable.dispose() }
                
                // simulate a tap
                barButtonItem.target?.performSelector(barButtonItem.action, withObject: barButtonItem)
                
                expect(receivedAction) == true
            }
            
            it("should support binding it's title") {
                let title = Observable("Hello")
                barButtonItem.b_title.bind(title)
                expect(barButtonItem.title) == "Hello"
                
                title.value = "World"
                expect(barButtonItem.title) == "World"
            }
        }
        
        describe("UIPageControl") {
            it("should support binding numberOfPages") {
                let numberOfPages = Observable(5)
                let pageControl = UIPageControl()
                
                pageControl.b_numberOfPages.bind(numberOfPages)
                expect(pageControl.numberOfPages) == 5
                
                numberOfPages.value = 11
                expect(pageControl.numberOfPages) == 11
            }
            
            it("should support binding currentPage") {
                let pageControl = UIPageControl()
                pageControl.numberOfPages = 11
                
                let currentPage = Observable(2)
                pageControl.b_currentPage.bind(currentPage)
                
                expect(pageControl.currentPage) == 2
                
                pageControl.currentPage += 1
                pageControl.sendActionsForControlEvents(.ValueChanged)
                
                expect(pageControl.currentPage) == 3
                expect(currentPage.value) == 3
                
                currentPage.value = 8
                
                expect(pageControl.currentPage) == 8
                expect(currentPage.value) == 8
            }
        }
        
        describe("UITableViewCell") {
            it("should support binding it's accessoryType value") {
                let accessoryType = Observable(UITableViewCellAccessoryType.None)
                
                let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
                cell.b_accessoryType.bind(accessoryType)
                expect(cell.accessoryType) == UITableViewCellAccessoryType.None
                
                accessoryType.value = .Checkmark
                expect(cell.accessoryType) == UITableViewCellAccessoryType.Checkmark
            }
        }
        
        describe("UISearchBar") {
            it("should support 2 way binding on its text value") {
                
                let value = Observable("Hello")
                let searchBar = UISearchBar()
                searchBar.b_text.bind(value)
                
                expect(searchBar.text) == "Hello"
                
                // pretend the user types " world"
                searchBar.text = (searchBar.text ?? "") + " world"
                searchBar.delegate?.searchBar?(searchBar, textDidChange: searchBar.text!)
                
                expect(searchBar.text) == "Hello world"
                expect(value.value) == "Hello world"
                
                // modify it programmatically
                value.value = "Bye"
                
                expect(searchBar.text) == "Bye"
                expect(value.value) == "Bye"
            }
        }
        
        describe("UISwitch") {
            it("should support 2 way binding on its 'on' value") {
                
                let on = Observable(false)
                let toggle = UISwitch()
                toggle.b_on.bind(on)
                
                expect(toggle.on) == false
                
                // pretend the user toggles switch ON
                toggle.on = true
                toggle.sendActionsForControlEvents(.ValueChanged)
                
                expect(toggle.on) == true
                expect(on.value) == true
                
                // modify it programmatically
                on.value = false
                
                expect(toggle.on) == false
                expect(on.value) == false
            }
        }
        
        describe("UISlider") {
            it("should support 2 way binding on its 'value' value") {
                
                let value = Observable(Float(0.0))
                let slider = UISlider()
                slider.minimumValue = 0.0
                slider.maximumValue = 1.0
                slider.value = 0.5
                slider.b_value.bind(value)
                
                expect(slider.value) == 0.0
                
                // pretend the user toggles switch ON
                slider.value = 0.5
                slider.sendActionsForControlEvents(.ValueChanged)
                
                expect(slider.value) == 0.5
                expect(value.value) == 0.5
                
                // modify it programmatically
                value.value = 0.25
                
                expect(slider.value) == 0.25
                expect(value.value) == 0.25
            }
        }
        
        describe("UISegmentedControl") {
            let items = Observable([1, 2, 3])
            let selection = Observable(1)
            
            let segmentedControl = UISegmentedControl()
            segmentedControl.b_configure(items, selection: selection, display: { segmentValue in
                .Title(String(segmentValue))
            })
            
            it("should update it's items when its `items` subscription changes") {
                items.value = [1, 2, 3, 4]
                
                let segments = (0..<segmentedControl.numberOfSegments).map { index in
                    segmentedControl.titleForSegmentAtIndex(index)
                }
                .flatMap { title in title }
                
                expect(segments) == ["1", "2", "3", "4"]
            }
            
            it("should keep its selection in sync with the specified `selection` observable") {
                selection.value = 2
                expect(segmentedControl.selectedSegmentIndex) == items.value.indexOf(selection.value)
                
                // Simulate the user switching selection
                segmentedControl.selectedSegmentIndex = 0
                segmentedControl.sendActionsForControlEvents(.ValueChanged)
                
                expect(selection.value) == items.value.first
            }
        }
    }
}
