//
//  UITableView+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import UIKit

public extension UITableView {
    
    func b_configure<T>(items: ObservableArray<T>, @noescape block: (TableViewConfig<T>) -> Void) {
        let config = TableViewConfig<T>()
        block(config)
        
        let delegate = TableViewDelegate(items: items, config: config)
        set("delegate", value: (delegate as AnyObject))
        
        self.delegate = delegate
        dataSource = delegate
        
        let subscription = items.subscribeArray { [weak self] _, _ in
            self?.reloadData()
        }
        set("delegateSubscription", value: subscription)
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

public class TableViewConfig<T> : NSObject {
    var cellIdentifier = ""
    var configureCell: ((T, UITableViewCell) -> Void) = { _, _ in }
    
    var onSelect: (T -> Void)?
    
    public var deselectRowOnSelection = true
    
    public var allowsDeletion = false
    
    public func usingCellIdentifier(cellIdentifier: String, configureCell: (T, UITableViewCell) -> Void) {
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell
    }
    
    public func onSelect(block: T -> Void) {
        onSelect = block
    }
}


private class TableViewDelegate<T> : NSObject, UITableViewDataSource, UITableViewDelegate {
    var items: ObservableArray<T>
    let config: TableViewConfig<T>
    
    init(items: ObservableArray<T>, config: TableViewConfig<T>) {
        self.items = items
        self.config = config
    }
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier, forIndexPath: indexPath)
        config.configureCell(items[indexPath.row], cell)
        return cell
    }
    
    
    //MARK: -
    
    @objc func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if config.deselectRowOnSelection {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        config.onSelect?(items[indexPath.row])
    }
    
    @objc func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return config.allowsDeletion
    }
    
    @objc func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return config.allowsDeletion ? .Delete : .None
    }
    
    @objc func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            items.removeAtIndex(indexPath.row)
            
        default:
            break
        }
    }
}
