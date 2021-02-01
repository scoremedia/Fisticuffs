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
    
    public func insertCells(indexPaths: [IndexPath]) {
        insertRows(at: indexPaths, with: .top)
    }
    
    public func deleteCells(indexPaths: [IndexPath]) {
        deleteRows(at: indexPaths, with: .top)
    }
    
    public func batchUpdates(_ updates: @escaping () -> Void) {
        beginUpdates()
        defer { endUpdates() }
        
        updates()
    }
    
    
    public func indexPathsForSelections() -> [IndexPath]? {
        indexPathsForSelectedRows
    }
    
    public func select(indexPath: IndexPath) {
        selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    public func deselect(indexPath: IndexPath) {
        deselectRow(at: indexPath, animated: false)
    }
    
    
    public func dequeueCell(reuseIdentifier: String, indexPath: IndexPath) -> UITableViewCell {
        dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    }
}


open class TableViewDataSource<Item: Equatable>: DataSource<Item, UITableView>, UITableViewDataSource, UITableViewDelegate {
    
    open var allowsDeletion = false
    
    public override init(subscribable: Subscribable<[Item]>, view: UITableView) {
        super.init(subscribable: subscribable, view: view)
    }
    
    //MARK: UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        numberOfSections()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfItems(section: section)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellAtIndexPath(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        editable && allowsMoving
    }
    
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        move(source: sourceIndexPath, destination: destinationIndexPath)
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        editable && (allowsDeletion || allowsMoving)
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(indexPath: indexPath)
        }
    }
    
    //MARK: UITableViewDelegate

    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // UITableView doesn't prevent "double selection" (selecting a currently selected cell again),
        // so we prevent that here (so it doesn't "spoil" our selections array)
        if tableView.indexPathsForSelectedRows?.contains(indexPath) == true {
            return false
        }

        if canSelect(indexPath: indexPath) == false {
            return false
        }

        return true
    }

    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // UITableView doesn't prevent "double selection" (selecting a currently selected cell again),
        // so we prevent that here (so it doesn't "spoil" our selections array)
        if tableView.indexPathsForSelectedRows?.contains(indexPath) == true {
            return nil
        }

        if canSelect(indexPath: indexPath) == false {
            return nil
        }
        
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(indexPath: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        didDeselect(indexPath: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        proposedDestinationIndexPath
    }
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        editable && allowsDeletion ? .delete : .none
    }
    
    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        allowsDeletion ? true : false
    }
    
}
