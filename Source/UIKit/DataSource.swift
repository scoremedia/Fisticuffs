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
    associatedtype CellView
    
    func reloadData()
    func insertCells(indexPaths: [IndexPath])
    func deleteCells(indexPaths: [IndexPath])
    func batchUpdates(_ updates: @escaping () -> Void)
    
    func indexPathsForSelections() -> [IndexPath]?
    func select(indexPath: IndexPath)
    func deselect(indexPath: IndexPath)
    
    func dequeueCell(reuseIdentifier: String, indexPath: IndexPath) -> CellView
}


open class DataSource<Item: Equatable, View: DataSourceView> : NSObject {
    fileprivate weak var view: View?
    
    // Underlying data
    fileprivate let subscribable: Subscribable<[Item]>
    fileprivate let observable: Observable<[Item]>?
    
    fileprivate var suppressChangeUpdates = false
    
    fileprivate var items: [Item] = []

    fileprivate var didInitialSelectionSync = false
    fileprivate var ignoreSelectionChanges: Bool = false
    fileprivate var selectionsSubscription: Disposable?
    fileprivate var selectionSubscription: Disposable?

    /// All selected items
    open var selections: Observable<[Item]>? {
        didSet {
            selectionsSubscription?.dispose()
            selectionsSubscription = selections?.subscribe { [weak self] _, newValue in
                if self?.ignoreSelectionChanges == true {
                    return
                }

                if let selection = self?.selection {
                    self?.ignoreSelectionChanges = true
                    if let selectionValue = selection.value {
                        if newValue.contains(selectionValue) == false {
                            selection.value = newValue.first
                        }
                    } else {
                        selection.value = newValue.first
                    }
                    self?.ignoreSelectionChanges = false
                }

                self?.syncSelections()
            }
        }
    }

    /// The selected item.  If multiple items are allowed/selected, it is undefined which one
    /// will show up in here.  Setting it will clear out `selections`
    open var selection: Observable<Item?>? {
        didSet {
            selectionSubscription?.dispose()
            selectionSubscription = selection?.subscribe { [weak self] _, newValue in
                if self?.ignoreSelectionChanges == true {
                    return
                }

                if let selections = self?.selections {
                    self?.ignoreSelectionChanges = true
                    if let newValue = newValue {
                        if selections.value.contains(newValue) == false {
                            selections.value.append(newValue)
                        }
                    } else {
                        selections.value = []
                    }
                    self?.ignoreSelectionChanges = false
                }

                self?.syncSelections()
            }
        }
    }


    fileprivate var disabledItemsSubscription: Disposable?
    fileprivate var disabledItemsValue: [Item] = []

    /// If set, will prevent the user from selecting these rows/items in collection/table views
    ///  NOTE: Won't adjust `selection`/`selections` properties (TODO: Should it?)
    open func disableSelectionFor(_ subscribable: Subscribable<[Item]>) {
        disabledItemsSubscription?.dispose()
        disabledItemsSubscription = subscribable.subscribe { [weak self] _, newValue in
            self?.disabledItemsValue = Array(newValue)
        }
    }

    
    open var deselectOnSelection = true
    open let onSelect = Event<Item>()
    open let onDeselect = Event<Item>()
    
    open var editable: Bool { return observable != nil }
    
    public init(subscribable: Subscribable<[Item]>, view: View) {
        self.view = view
        self.subscribable = subscribable
        self.observable = subscribable as? Observable<[Item]>
        super.init()
        subscribable.subscribeArray(SubscriptionOptions()) { [weak self] new, change in
            self?.underlyingDataChanged(new, change)
        }
    }
    
    fileprivate var reuseIdentifier: String?
    fileprivate var cellSetup: ((Item, View.CellView) -> Void)?
    
    open func useCell(reuseIdentifier: String, setup: @escaping (Item, View.CellView) -> Void) {
        self.reuseIdentifier = reuseIdentifier
        cellSetup = setup
    }
    
    open var allowsMoving = false
}

extension DataSource {
    
    func underlyingDataChanged(_ new: [Item], _ change: ArrayChange<Item>) {
        items = Array(new)
        
        if suppressChangeUpdates == false {
            switch change {
            case .set(elements: _):
                view?.reloadData()
                
            case let .insert(index: index, newElements: newElements):
                let indexPaths = (index ..< index + newElements.count).map { i in IndexPath(item: i, section: 0) }
                view?.insertCells(indexPaths: indexPaths)
            
            case let .remove(range: range, removedElements: _):
                let indexPaths = range.map { i in IndexPath(item: i, section: 0) }
                view?.deleteCells(indexPaths: indexPaths)
                
            case let .replace(range: range, removedElements: _, newElements: new):
                view?.batchUpdates { [view = view] in
                    let deleted = range.map { i in IndexPath(item: i, section: 0) }
                    view?.deleteCells(indexPaths: deleted)
                    
                    let addedRange = range.lowerBound ..< range.lowerBound + new.count
                    let added = addedRange.map { i in IndexPath(item: i, section: 0) }
                    view?.insertCells(indexPaths: added)
                }
            }
        }
        
        syncSelections()
    }
    
    func syncSelections() {
        guard let view = view else { return }

        var selectedItems: [Item] = []
        if let selections = selections {
            selectedItems = selections.value
        } else if let selection = selection {
            if let value = selection.value {
                selectedItems = [value]
            }
        } else {
            // no selection binding setup
            return
        }
        
        let currentSelections = Set(view.indexPathsForSelections() ?? [])
        
        let expectedSelections: Set<IndexPath> = {
            let expected = selectedItems.map { item -> IndexPath? in
                items.index(of: item).map { index in
                    IndexPath(item: index, section: 0)
                }
            }
            return Set(expected.flatMap { $0 })
        }()
        
        let toDeselect = currentSelections.subtracting(expectedSelections)
        toDeselect.forEach(view.deselect)

        let toSelect = expectedSelections.subtracting(currentSelections)
        toSelect.forEach(view.select)
    }
    
}

extension DataSource {
    public func numberOfSections() -> Int {
        // Sadly this is the best place to hook into this... If we try to sync 
        // selections before the table/collection view has been loaded (ie, when 
        // setting up its bindings), it won't save those selections.  This triggers a
        // sync again after the table/collection view has loaded its data
        if didInitialSelectionSync == false {
            didInitialSelectionSync = true
            DispatchQueue.main.async {
                self.syncSelections()
            }
        }

        return 1
    }
    
    public func numberOfItems(section: Int) -> Int {
        return items.count
    }
    
    public func itemAtIndexPath(_ indexPath: IndexPath) -> Item {
        return items[(indexPath as NSIndexPath).item]
    }
    
    public func cellAtIndexPath(_ indexPath: IndexPath) -> View.CellView {
        guard let view = view else {
            preconditionFailure("view not set")
        }
        
        guard let reuseIdentifier = reuseIdentifier, let cellSetup = cellSetup else {
            preconditionFailure("Cell reuseidentifier/setup block not set")
        }
        
        let item = itemAtIndexPath(indexPath)
        let cell = view.dequeueCell(reuseIdentifier: reuseIdentifier, indexPath: indexPath)
        cellSetup(item, cell)
        return cell
    }
    
    public func didSelect(indexPath: IndexPath) {
        let item = itemAtIndexPath(indexPath)

        self.ignoreSelectionChanges = true
        do {
            selections?.value.append(item)
            if selection?.value != item {
                selection?.value = item
            }
        }
        self.ignoreSelectionChanges = false

        onSelect.fire(item)
        
        if deselectOnSelection {
            view?.deselect(indexPath: indexPath)
            didDeselect(indexPath: indexPath)
        }
    }
    
    public func didDeselect(indexPath: IndexPath) {
        let item = itemAtIndexPath(indexPath)

        self.ignoreSelectionChanges = true
        do {
            if let index = selections?.value.index(of: item) {
                selections?.value.remove(at: index)
            }
            if selection?.value == item {
                // reset back to the first multiple selection (or none if there isn't one)
                selection?.value = selections?.value.first
            }
        }
        self.ignoreSelectionChanges = false

        onDeselect.fire(item)
    }

    public func canSelect(indexPath: IndexPath) -> Bool {
        let item = itemAtIndexPath(indexPath)
        return disabledItemsValue.contains(item) == false
    }
}

extension DataSource {
    
    func modifyUnderlyingData(suppressChangeUpdates suppress: Bool, block: (_ data: Observable<[Item]>) -> Void) {
        suppressChangeUpdates = suppress
        defer { suppressChangeUpdates = false }
        
        assert(editable, "Underlying data must be editable")
        guard let observable = observable else {
            assertionFailure("Must have an observable to modify")
            return
        }
        
        block(observable)
    }
    
    public func move(source: IndexPath, destination: IndexPath) {
        // No need to send updates to the view (suppressChangeUpdates: true) for the moving items, 
        // as that is handled internally by UITableView / UICollectionView
        modifyUnderlyingData(suppressChangeUpdates: true) { data in
            let sourceIndex = data.value.startIndex.advanced(by: source.item)
            let item = data.value.remove(at: sourceIndex)
            
            let destIndex = data.value.startIndex.advanced(by: destination.item)
            data.value.insert(item, at: destIndex)
        }
    }
    
    public func delete(indexPath: IndexPath) {
        modifyUnderlyingData(suppressChangeUpdates: false) { data in
            let index = data.value.startIndex.advanced(by: indexPath.item)
            data.value.remove(at: index)
        }
    }
    
}

