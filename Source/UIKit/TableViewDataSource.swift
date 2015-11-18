//
//  TableViewDataSource.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-18.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit

extension UITableView: DataSourceView {
    public typealias CellView = UITableViewCell
    
    public func indexPathsForSelections() -> [NSIndexPath]? {
        return indexPathsForSelectedRows
    }
    
    public func select(indexPath indexPath: NSIndexPath) {
        selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
    }
    
    public func deselect(indexPath indexPath: NSIndexPath) {
        deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    public func dequeueCell(reuseIdentifier reuseIdentifier: String, indexPath: NSIndexPath) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
    }
}


public class TableViewDataSource<S: SubscribableType where S.ValueType: RangeReplaceableCollectionType, S.ValueType.Generator.Element: Equatable>: DataSource<S, UITableView>, UITableViewDataSource, UITableViewDelegate {
    
    public override init(subscribable: S, view: UITableView) {
        super.init(subscribable: subscribable, view: view)
    }
    
    //MARK: UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(section: section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellAtIndexPath(indexPath)
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return editable && allowsMoving
    }
    
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        move(source: sourceIndexPath, destination: destinationIndexPath)
    }
    
    //MARK: UITableViewDelegate
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelect(indexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        didDeselect(indexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        return proposedDestinationIndexPath
    }
    
}
