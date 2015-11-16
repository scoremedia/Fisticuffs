//
//  UISegmentedControl+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

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
