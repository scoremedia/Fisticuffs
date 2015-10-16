//
//  UITableView+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-15.
//
//

import UIKit

public extension UITableView {
        
    func b_configure<T>(items: Observable<[T]>, @noescape block: (TableViewConfig<T>) -> Void) {
        b_configure(ArrayAdapter.forObservable(items), block: block)
    }
    
    private func b_configure<T>(adapter: ArrayAdapter<T>, @noescape block: (TableViewConfig<T>) -> Void) {
        let config = TableViewConfig<T>()
        block(config)
        
        let delegate = TableViewDelegate(adapter: adapter, tableView: self, config: config)
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
    public var allowsReordering = false
    
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
    var adapter: ArrayAdapter<T>
    let config: TableViewConfig<T>
    
    var suppressChangeNotifications = false
    let disposeBag = DisposableBag()
    
    
    init(adapter: ArrayAdapter<T>, tableView: UITableView, config: TableViewConfig<T>) {
        self.adapter = adapter
        self.tableView = tableView
        self.config = config
        
        super.init()
        
        adapter.subscribe { [weak self] _, change in
            self?.applyChange(change)
        }
        .addTo(disposeBag)
    }
    
    private func applyChange(change: ArrayChange<T>) {
        if suppressChangeNotifications {
            return
        }
        
        switch change {
        case .Set:
            tableView?.reloadData()
            
        case let .Insert(index, newElements):
            let indexPaths = (index ..< index + newElements.count).map { row in NSIndexPath(forRow: row, inSection: 0) }
            
            let isAppending = index == adapter.count - newElements.count
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
    
    private func withoutChangeNotifications(@noescape block: Void -> Void) {
        suppressChangeNotifications = true
        block()
        suppressChangeNotifications = false
    }
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adapter.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier, forIndexPath: indexPath)
        cell.showsReorderControl = config.allowsReordering
        config.configureCell(adapter[indexPath.row], cell)
        return cell
    }
    
    
    //MARK: -
    
    @objc func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if config.deselectRowOnSelection {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        config.onSelect?(adapter[indexPath.row])
    }
    
    //MARK: -
    
    @objc func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return config.allowsDeletion
    }
    
    @objc func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return config.allowsDeletion ? .Delete : .None
    }
    
    @objc func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            adapter.removeAtIndex(indexPath.row)
            
        default:
            break
        }
    }
    
    //MARK: -
    
    @objc func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return config.allowsReordering
    }
    
    @objc func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        return proposedDestinationIndexPath
    }
    
    @objc func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        withoutChangeNotifications {
            let item = adapter.removeAtIndex(sourceIndexPath.row)
            adapter.insert(item, atIndex: destinationIndexPath.row)
        }
    }
}
