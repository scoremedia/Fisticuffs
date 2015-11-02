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
    
    func b_configure<T: Equatable>(items: Observable<[T]>, selection: Observable<T>, display: (T) -> SegmentDisplay) {
        let manager = SegmentControlManager(control: self, items: items, display: display, selection: selection)
        set("manager", value: (manager as AnyObject))
    }
}

private class SegmentControlManager<T: Equatable> : NSObject {
    weak var control: UISegmentedControl?
    let items: Observable<[T]>
    let display: (T) -> SegmentDisplay
    let selection: Observable<T>
    
    let disposableBag = DisposableBag()
    
    init(control: UISegmentedControl, items: Observable<[T]>, display: (T) -> SegmentDisplay, selection: Observable<T>) {
        self.control = control
        self.items = items
        self.display = display
        self.selection = selection
        super.init()
        
        items.subscribe { [weak self] value in
            self?.itemsChanged(value)
        }
        .addTo(disposableBag)
        
        selection.subscribe { [weak self] value in
            self?.selectionChanged(value)
        }
        .addTo(disposableBag)
        
        control.addTarget(self, action: "userChangedSelection:", forControlEvents: .ValueChanged)
    }
    
    deinit {
        control?.removeTarget(self, action: "userChangedSelection:", forControlEvents: .ValueChanged)
    }
    
    func itemsChanged(newValue: [T]) {
        guard let control = control else { return }
        
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
    
    func selectionChanged(newValue: T) {
        guard let control = control else { return }
        
        if let index = items.value.indexOf(newValue) {
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
        
        selection.value = items.value[control.selectedSegmentIndex]
    }
    
}
