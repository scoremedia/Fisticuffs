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

import UIKit

public enum SegmentDisplay {
    case Title(String)
    case Image(UIImage)
}

public extension UISegmentedControl {
    
    func b_configure<S: Subscribable where
            S.ValueType: CollectionType,
            S.ValueType.Index == Int,
            S.ValueType.Generator.Element: Equatable>(items: S, selection: Observable<S.ValueType.Generator.Element>, display: (S.ValueType.Generator.Element) -> SegmentDisplay) {
        let manager = SegmentControlManager<S>(control: self, items: items, display: display, selection: selection)
        set("manager", value: (manager as AnyObject))
    }
}

private class SegmentControlManager<S: Subscribable where S.ValueType: CollectionType, S.ValueType.Index == Int, S.ValueType.Generator.Element: Equatable> : NSObject {
    typealias ItemType = S.ValueType.Generator.Element
    
    weak var control: UISegmentedControl?
    let items: S
    var itemValues: [ItemType] = []
    let display: (ItemType) -> SegmentDisplay
    let selection: Observable<ItemType>
    
    let disposableBag = DisposableBag()
    
    init(control: UISegmentedControl, items: S, display: (ItemType) -> SegmentDisplay, selection: Observable<ItemType>) {
        self.control = control
        self.items = items
        self.display = display
        self.selection = selection
        super.init()
        
        items.subscribe { [weak self] _, value in
            self?.itemsChanged(value)
        }
        .addTo(disposableBag)
        
        selection.subscribe { [weak self] _, value in
            self?.selectionChanged(value)
        }
        .addTo(disposableBag)
        
        control.addTarget(self, action: "userChangedSelection:", forControlEvents: .ValueChanged)
    }
    
    deinit {
        control?.removeTarget(self, action: "userChangedSelection:", forControlEvents: .ValueChanged)
    }
    
    func itemsChanged(newValue: S.ValueType) {
        guard let control = control else { return }
        
        itemValues = Array(newValue)
        
        control.removeAllSegments()
        for (index, item) in newValue.enumerate() {
            let displayItem = display(item)
            
            switch displayItem {
            case let .Title(title):
                control.insertSegmentWithTitle(title, atIndex: index, animated: false)
            case let .Image(image):
                control.insertSegmentWithImage(image, atIndex: index, animated: false)
            }
        }
        
        if let index = newValue.indexOf(selection.value) {
            control.selectedSegmentIndex = index
        }
        else {
            control.selectedSegmentIndex = UISegmentedControlNoSegment
        }
    }
    
    func selectionChanged(newValue: ItemType) {
        guard let control = control else { return }
        
        if let index = itemValues.indexOf(newValue) {
            if index != control.selectedSegmentIndex {
                control.selectedSegmentIndex = index
            }
        }
        else {
            control.selectedSegmentIndex = UISegmentedControlNoSegment
        }
    }
    
    @IBAction func userChangedSelection(sender: AnyObject) {
        guard let control = control else { return }
        
        selection.value = itemValues[control.selectedSegmentIndex]
    }
    
}
