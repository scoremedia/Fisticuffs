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
        
        let delegate = TableViewDelegate(items: items, tableView: self, config: config)
        set("delegate", value: (delegate as AnyObject))
        
        self.delegate = delegate
        dataSource = delegate
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
    weak var tableView: UITableView?
    var items: ObservableArray<T>
    let config: TableViewConfig<T>
    
    let disposeBag = DisposableBag()
    
    
    init(items: ObservableArray<T>, tableView: UITableView, config: TableViewConfig<T>) {
        self.items = items
        self.tableView = tableView
        self.config = config
        
        super.init()
        
        items.subscribeArray { [weak self] _, change in
            self?.applyChange(change)
        }
        .addTo(disposeBag)
    }
    
    private func applyChange(change: ArrayChange<T>) {
        switch change {
        case .Initial:
            tableView?.reloadData()
            
        case let .Insert(index, newElements):
            let indexPaths = (index ..< index + newElements.count).map { row in NSIndexPath(forRow: row, inSection: 0) }
            
            let isAppending = index == items.count - newElements.count
            let animation = isAppending ? UITableViewRowAnimation.None : .Top
            tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
            
        case let .Remove(range, _):
            let indexPaths = range.map { row in NSIndexPath(forRow: row, inSection: 0) }
            let animation = tableView?.editing == true ? UITableViewRowAnimation.Right : .Top
            tableView?.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
            
        case let .Replace(range, removedElements, newElements):
            if range.count == removedElements.count {
                // replaced all items, just reload
                tableView?.reloadData()
            }
            else {
                tableView?.beginUpdates()
                
                let deleted = range.map { row in NSIndexPath(forRow: row, inSection: 0) }
                tableView?.deleteRowsAtIndexPaths(deleted, withRowAnimation: .Top)
                
                let addedIndexes = range.startIndex ..< range.startIndex + newElements.count
                let added = addedIndexes.map { row in NSIndexPath(forRow: row, inSection: 0) }
                tableView?.insertRowsAtIndexPaths(added, withRowAnimation: .Top)
                
                tableView?.endUpdates()
            }
        }
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
