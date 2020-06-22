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
                expect(control.isEnabled) == false
                
                enabled.value = true
                expect(control.isEnabled) == true
            }
            
            it("should allow subscribing to arbitrary control events") {
                var receivedEvent = false
                
                let control = UIControl()
                _ = control.b_controlEvent(.allEvents).subscribe { receivedEvent = true }

                control.sendActions(for: .editingDidBegin)
                expect(receivedEvent) == true
            }
        }
        
        describe("UIButton") {
            it("should support binding an action for when the user taps") {
                var receivedTap = false
                
                let button = UIButton()
                _ = button.b_onTap.subscribe { receivedTap = true }

                button.sendActions(for: .touchUpInside)

                expect(receivedTap) == true
            }
        }
        
        describe("UIDatePicker") {
            it("should support 2 way binding on its text value") {
                
                let initial = Date()
                
                let value = Observable(initial)
                let datePicker = UIDatePicker()
                datePicker.b_date.bind(value)
                
                expect(datePicker.date) == initial
                
                // pretend the user goes to the next day
                let tomorrow = initial.addingTimeInterval(24 * 60 * 60)
                datePicker.date = tomorrow
                datePicker.sendActions(for: .valueChanged)
                
                expect(datePicker.date) == tomorrow
                expect(value.value) == tomorrow
                
                // modify it programmatically
                let yesterday = initial.addingTimeInterval(-24 * 60 * 60)
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
                textField.sendActions(for: .editingChanged)

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
                _ = barButtonItem.target?.perform(barButtonItem.action, with: barButtonItem)
                
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
                pageControl.sendActions(for: .valueChanged)

                expect(pageControl.currentPage) == 3
                expect(currentPage.value) == 3
                
                currentPage.value = 8
                
                expect(pageControl.currentPage) == 8
                expect(currentPage.value) == 8
            }
        }
        
        describe("UITableViewCell") {
            it("should support binding it's accessoryType value") {
                let accessoryType = Observable(UITableViewCell.AccessoryType.none)
                
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.b_accessoryType.bind(accessoryType)
                expect(cell.accessoryType) == UITableViewCell.AccessoryType.none
                
                accessoryType.value = .checkmark
                expect(cell.accessoryType) == UITableViewCell.AccessoryType.checkmark
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
                
                expect(toggle.isOn) == false
                
                // pretend the user toggles switch ON
                toggle.isOn = true
                toggle.sendActions(for: .valueChanged)
                
                expect(toggle.isOn) == true
                expect(on.value) == true
                
                // modify it programmatically
                on.value = false
                
                expect(toggle.isOn) == false
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
                slider.sendActions(for: .valueChanged)
                
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
                .title(String(segmentValue))
            })
            
            it("should update it's items when its `items` subscription changes") {
                items.value = [1, 2, 3, 4]
                
                let segments = (0..<segmentedControl.numberOfSegments).map { index in
                    segmentedControl.titleForSegment(at: index)
                }
                .compactMap { title in title }
                
                expect(segments) == ["1", "2", "3", "4"]
            }
            
            it("should keep its selection in sync with the specified `selection` observable") {
                selection.value = 2
                expect(segmentedControl.selectedSegmentIndex) == items.value.firstIndex(of: selection.value)
                
                // Simulate the user switching selection
                segmentedControl.selectedSegmentIndex = 0
                segmentedControl.sendActions(for: .valueChanged)
                
                expect(selection.value) == items.value.first
            }
        }

        describe("UIAlertAction") {
            it("should support binding its enabled value") {
                let enabled = Observable(false)

                let action = UIAlertAction(title: "Test", style: .default, handler: nil)
                action.b_enabled.bind(enabled)
                expect(action.isEnabled) == false

                enabled.value = true
                expect(action.isEnabled) == true
            }
        }

        describe("UICollectionView") {
            it("should not crash when adding/deleting items before the collection view has appeared on screen") {
                let items = Observable<[Int]>([1, 2, 3])

                let reuseIdentifier = "Cell"

                let frame = CGRect(x: 0, y: 0, width: 320, height: 480)
                let layout = UICollectionViewFlowLayout()
                let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
                collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

                collectionView.b_configure(items, block: { config in
                    config.useCell(reuseIdentifier: reuseIdentifier) { _, _ in }
                })

                items.value.append(5)
            }
        }
    }
}
