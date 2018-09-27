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

private var manager_key = 0


public enum SegmentDisplay {
    case title(String)
    case image(UIImage)
}

public extension UISegmentedControl {
    
    func b_configure<Item: Equatable>(_ items: Subscribable<[Item]>, selection: Observable<Item>, display: @escaping (Item) -> SegmentDisplay) {
        let manager = SegmentControlManager<Item>(control: self, items: items, display: display, selection: selection)
        setAssociatedObjectProperty(self, &manager_key, value: manager as AnyObject)
    }
}

private class SegmentControlManager<Item: Equatable> : NSObject {
    weak var control: UISegmentedControl?
    let items: Subscribable<[Item]>
    var itemValues: [Item] = []
    let display: (Item) -> SegmentDisplay
    let selection: Observable<Item>
    
    let disposableBag = DisposableBag()
    
    init(control: UISegmentedControl, items: Subscribable<[Item]>, display: @escaping (Item) -> SegmentDisplay, selection: Observable<Item>) {
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
        
        control.addTarget(self, action: #selector(SegmentControlManager.userChangedSelection(_:)), for: .valueChanged)
    }
    
    deinit {
        control?.removeTarget(self, action: #selector(SegmentControlManager.userChangedSelection(_:)), for: .valueChanged)
    }
    
    func itemsChanged(_ newValue: [Item]) {
        guard let control = control else { return }
        
        itemValues = Array(newValue)
        
        control.removeAllSegments()
        for (index, item) in newValue.enumerated() {
            let displayItem = display(item)
            
            switch displayItem {
            case let .title(title):
                control.insertSegment(withTitle: title, at: index, animated: false)
            case let .image(image):
                control.insertSegment(with: image, at: index, animated: false)
            }
        }
        
        if let index = newValue.index(of: selection.value) {
            control.selectedSegmentIndex = index
        }
        else {
            control.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }
    
    func selectionChanged(_ newValue: Item) {
        guard let control = control else { return }
        
        if let index = itemValues.index(of: newValue) {
            if index != control.selectedSegmentIndex {
                control.selectedSegmentIndex = index
            }
        }
        else {
            control.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }
    
    @IBAction func userChangedSelection(_ sender: AnyObject) {
        guard let control = control else { return }
        
        selection.value = itemValues[control.selectedSegmentIndex]
    }
    
}
