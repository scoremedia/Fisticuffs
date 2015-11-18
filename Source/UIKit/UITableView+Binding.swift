//
//  UITableView+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import UIKit

public extension UITableView {
        
    func b_configure<S: Subscribable where
        S.ValueType: CollectionType,
        S.ValueType.Index == Int,
        S.ValueType.Generator.Element: Equatable>(items: S, @noescape block: (TableViewDataSource<S>) -> Void) {
            
            let dataSource = TableViewDataSource(subscribable: items, view: self)
            block(dataSource)
            
            set("dataSource", value: dataSource as AnyObject)
            
            self.delegate = dataSource
            self.dataSource = dataSource
            
    }

    
    var b_editing: Observable<Bool>? {
        get {
            return getObservableFor("editing")
        }
        set (value) {
            setObservableFor("editing", observable: value) {
                [weak self] editing in
                self?.editing = editing
            }
        }
    }
    
}