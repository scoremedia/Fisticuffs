//
//  UITableView+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import UIKit

public extension UITableView {
    
    func b_items<T>(items: ObservableArray<T>, cellIdentifier: String, configureCell: (T, UITableViewCell) -> Void) {
        let delegate = TableViewDelegate(items: items, cellIdentifier: cellIdentifier, configureCell: configureCell)
        set("delegate", value: (delegate as AnyObject))
        
        self.delegate = delegate
        dataSource = delegate
        
        let subscription = items.subscribeArray { [weak self] _, _ in
            self?.reloadData()
        }
        set("delegateSubscription", value: subscription)
    }
    
}


private class TableViewDelegate<T> : NSObject, UITableViewDataSource, UITableViewDelegate {
    let items: ObservableArray<T>
    let cellIdentifier: String
    let configureCell: (T, UITableViewCell) -> Void
    
    init(items: ObservableArray<T>, cellIdentifier: String, configureCell: (T, UITableViewCell) -> Void) {
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell
    }
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        configureCell(items[indexPath.row], cell)
        return cell
    }
    
}
