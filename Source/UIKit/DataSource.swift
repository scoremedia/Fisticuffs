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


public class DataSource<S: SubscribableType, View: DataSourceView where S.ValueType: RangeReplaceableCollectionType, S.ValueType.Generator.Element: Equatable> : NSObject {
    typealias Collection = S.ValueType
    typealias Item = Collection.Generator.Element
    
    private weak var view: View?
    
    // Underlying data
    private let subscribable: S
    private let observable: Observable<Collection>?
    
    private var suppressChangeNotifications = false
    
    private var items: [Item] = []
    
    private var selectionSubscription: Disposable?
    public var selections: Observable<[Item]>? {
        didSet {
            selectionSubscription?.dispose()
            selectionSubscription = selections?.subscribe { [weak self] in
                self?.syncSelections()
            }
        }
    }
    
    
    public var deselectOnSelection = true
    public let onSelect = Event<Item>()
    public let onDeselect = Event<Item>()
    
    public var editable: Bool { return observable != nil }
    
    public init(subscribable: S, view: View) {
        self.view = view
        self.subscribable = subscribable
        self.observable = subscribable as? Observable<Collection>
        super.init()
        subscribable.subscribeArray(SubscriptionOptions()) { [weak self] new, change in
            self?.underlyingDataChanged(new, change)
        }
    }
    
    private var reuseIdentifier: String?
    private var cellSetup: ((Item, View.CellView) -> Void)?
    
    public func useCell(reuseIdentifier reuseIdentifier: String, setup: (Item, View.CellView) -> Void) {
        self.reuseIdentifier = reuseIdentifier
        cellSetup = setup
    }
    
    public var allowsMoving = false
}

extension DataSource {
    
    func underlyingDataChanged(new: [Item], _ change: ArrayChange<Item>) {
        guard suppressChangeNotifications == false else { return }
        
        items = Array(new)
        
        switch change {
        case .Set(elements: _):
            view?.reloadData()
            
        case let .Insert(index: index, newElements: newElements):
            let indexPaths = (index ..< index + newElements.count).map { i in NSIndexPath(forItem: i, inSection: 0) }
            view?.insertCells(indexPaths: indexPaths)
        
        case let .Remove(range: range, removedElements: _):
            let indexPaths = range.map { i in NSIndexPath(forItem: i, inSection: 0) }
            view?.deleteCells(indexPaths: indexPaths)
            
        case let .Replace(range: range, removedElements: _, newElements: new):
            view?.batchUpdates { [view = view] in
                let deleted = range.map { i in NSIndexPath(forItem: i, inSection: 0) }
                view?.deleteCells(indexPaths: deleted)
                
                let addedRange = range.startIndex ..< range.startIndex + new.count
                let added = addedRange.map { i in NSIndexPath(forItem: i, inSection: 0) }
                view?.insertCells(indexPaths: added)
            }
        }
        
        syncSelections()
    }
    
    func syncSelections() {
        guard let view = view, selections = selections else { return }
        
        let currentSelections = Set(view.indexPathsForSelections() ?? [])
        
        let expectedSelections: Set<NSIndexPath> = {
            let expected = selections.value.map { item -> NSIndexPath? in
                items.indexOf(item).map { index in
                    NSIndexPath(forItem: index, inSection: 0)
                }
            }
            return Set(expected.flatMap { $0 })
        }()
        
        let toDeselect = currentSelections.subtract(expectedSelections)
        toDeselect.forEach(view.deselect)

        let toSelect = expectedSelections.subtract(currentSelections)
        toSelect.forEach(view.select)
    }
    
}

extension DataSource {
    public func numberOfSections() -> Int {
        return 1
    }
    
    public func numberOfItems(section section: Int) -> Int {
        return items.count
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> Item {
        return items[indexPath.item]
    }
    
    public func cellAtIndexPath(indexPath: NSIndexPath) -> View.CellView {
        guard let view = view else {
            preconditionFailure("view not set")
        }
        
        guard let reuseIdentifier = reuseIdentifier, cellSetup = cellSetup else {
            preconditionFailure("Cell reuseidentifier/setup block not set")
        }
        
        let item = itemAtIndexPath(indexPath)
        let cell = view.dequeueCell(reuseIdentifier: reuseIdentifier, indexPath: indexPath)
        cellSetup(item, cell)
        return cell
    }
    
    public func didSelect(indexPath indexPath: NSIndexPath) {
        let item = itemAtIndexPath(indexPath)
        selections?.value.append(item)
        onSelect.fire(item)
        
        if deselectOnSelection {
            view?.deselect(indexPath: indexPath)
            didDeselect(indexPath: indexPath)
        }
    }
    
    public func didDeselect(indexPath indexPath: NSIndexPath) {
        let item = itemAtIndexPath(indexPath)
        if let index = selections?.value.indexOf(item) {
            selections?.value.removeAtIndex(index)
        }
        onDeselect.fire(item)
    }
}

extension DataSource {
    
    func modifyUnderlyingData(suppressChangeNotifications suppress: Bool, @noescape block: (data: Observable<Collection>) -> Void) {
        suppressChangeNotifications = suppress
        defer { suppressChangeNotifications = false }
        
        assert(editable, "Underlying data must be editable")
        guard let observable = observable else {
            assertionFailure("Must have an observable to modify")
            return
        }
        
        block(data: observable)
    }
    
    public func move(source source: NSIndexPath, destination: NSIndexPath) {
        modifyUnderlyingData(suppressChangeNotifications: true) { data in
            let sourceIndex = data.value.startIndex.nthSuccessor(source.item)
            let item = data.value.removeAtIndex(sourceIndex)
            
            let destIndex = data.value.startIndex.nthSuccessor(destination.item)
            data.value.insert(item, atIndex: destIndex)
        }
    }
    
    public func delete(indexPath indexPath: NSIndexPath) {
        modifyUnderlyingData(suppressChangeNotifications: false) { data in
            let index = data.value.startIndex.nthSuccessor(indexPath.item)
            data.value.removeAtIndex(index)
        }
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

