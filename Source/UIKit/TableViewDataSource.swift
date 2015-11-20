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

extension UITableView: DataSourceView {
    public typealias CellView = UITableViewCell
    
    public func insertCells(indexPaths indexPaths: [NSIndexPath]) {
        insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
    }
    
    public func deleteCells(indexPaths indexPaths: [NSIndexPath]) {
        deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
    }
    
    public func batchUpdates(updates: () -> Void) {
        beginUpdates()
        defer { endUpdates() }
        
        updates()
    }
    
    
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
    
    public var allowsDeletion = false
    
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
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return editable && (allowsDeletion || allowsMoving)
    }
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            delete(indexPath: indexPath)
        }
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
    
    public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return editable && allowsDeletion ? .Delete : .None
    }
    
    public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return allowsDeletion ? true : false
    }
    
}
