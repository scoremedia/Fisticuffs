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

public protocol DataSourceView: class {
    typealias CellView
    
    func reloadData()
    func insertCells(indexPaths indexPaths: [NSIndexPath])
    func deleteCells(indexPaths indexPaths: [NSIndexPath])
    func batchUpdates(updates: () -> Void)
    
    func indexPathsForSelections() -> [NSIndexPath]?
    func select(indexPath indexPath: NSIndexPath)
    func deselect(indexPath indexPath: NSIndexPath)
    
    func dequeueCell(reuseIdentifier reuseIdentifier: String, indexPath: NSIndexPath) -> CellView
}


public class DataSource<Item: Equatable, View: DataSourceView> : NSObject {
    weak var view: View?
    let section: Section<Item, View>
    
    /// All selected items
    public var selections: Observable<[Item]>? {
        get { return section.selections }
        set { section.selections = newValue }
    }

    /// The selected item.  If multiple items are allowed/selected, it is undefined which one
    /// will show up in here.  Setting it will clear out `selections`
    public var selection: Observable<Item?>? {
        get { return section.selection }
        set { section.selection = newValue }
    }

    /// If set, will prevent the user from selecting these rows/items in collection/table views
    ///  NOTE: Won't adjust `selection`/`selections` properties (TODO: Should it?)
    public func disableSelectionFor(subscribable: Subscribable<[Item]>) {
        section.disableSelectionFor(subscribable)
    }

    
    public var deselectOnSelection: Bool {
        get { return section.deselectOnSelection }
        set { section.deselectOnSelection = newValue }
    }
    public var onSelect: Event<Item> {
        return section.onSelect
    }
    public var onDeselect:  Event<Item> {
        return section.onDeselect
    }
    
    public var editable: Bool { return section.editable }
    
    public convenience init(subscribable: Subscribable<[Item]>, view: View) {
        let section = Section<Item, View>(subscribable: subscribable)
        self.init(view: view, section: section)
    }

    public init(view: View, section: Section<Item, View>) {
        self.view = view
        self.section = section
        super.init()
        section.parent = self
    }
    
    public func useCell(reuseIdentifier reuseIdentifier: String, setup: (Item, View.CellView) -> Void) {
        section.useCell(reuseIdentifier: reuseIdentifier, setup: setup)
    }
    
    public var allowsMoving: Bool {
        get { return section.allowsMoving }
        set { section.allowsMoving = newValue }
    }
}

extension DataSource {
    public func numberOfSections() -> Int {
        return 1
    }
    
    public func numberOfItems(section section: Int) -> Int {
        return self.section.numberOfItems(section: section)
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> Item {
        return self.section.itemAtIndexPath(indexPath)
    }
    
    public func cellAtIndexPath(indexPath: NSIndexPath) -> View.CellView {
        return self.section.cellAtIndexPath(indexPath)
    }
    
    public func didSelect(indexPath indexPath: NSIndexPath) {
        self.section.didSelect(indexPath: indexPath)
    }
    
    public func didDeselect(indexPath indexPath: NSIndexPath) {
        self.section.didDeselect(indexPath: indexPath)
    }

    public func canSelect(indexPath indexPath: NSIndexPath) -> Bool {
        return self.section.canSelect(indexPath: indexPath)
    }
}

extension DataSource {
    
    public func move(source source: NSIndexPath, destination: NSIndexPath) {
        self.section.move(source: source, destination: destination)
    }
    
    public func delete(indexPath indexPath: NSIndexPath) {
        self.section.delete(indexPath: indexPath)
    }
    
}

extension ForwardIndexType {
    func nthSuccessor(n: Int) -> Self {
        assert(n >= 0, "`n` must be positive")
        
        var index = self
        for _ in 0 ..< n {
            index = index.successor()
        }
        return index
    }
}

