//
//  UICollectionView+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import UIKit

public extension UICollectionView {
    
    func b_configure<S: Subscribable where
            S.ValueType: CollectionType,
            S.ValueType.Index == Int,
            S.ValueType.Generator.Element: Equatable>(items: S, @noescape block: (CollectionViewConfig<S.ValueType.Generator.Element>) -> Void) {
        let config = CollectionViewConfig<S.ValueType.Generator.Element>()
        block(config)
        
        let delegate = CollectionViewDelegate(items: items, collectionView: self, config: config)
        set("delegate", value: (delegate as AnyObject))
        
        self.delegate = delegate
        dataSource = delegate
    }
}

public class CollectionViewConfig<T> : NSObject {
    var cellIdentifier = ""
    var configureCell: ((T, UICollectionViewCell) -> Void) = { _, _ in }
    
    public var selections: Observable<[T]>?
    
    public func usingCellIdentifier(cellIdentifier: String, configureCell: (T, UICollectionViewCell) -> Void) {
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell
    }
}

private class CollectionViewDelegate<S: Subscribable where
        S.ValueType: CollectionType,
        S.ValueType.Index == Int,
        S.ValueType.Generator.Element: Equatable> : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    typealias ItemType = S.ValueType.Generator.Element
    
    weak var collectionView: UICollectionView?
    var items: [ItemType]
    let config: CollectionViewConfig<ItemType>
    
    var suppressChangeNotifications = false
    let disposeBag = DisposableBag()
    
    
    init(items: S, collectionView: UICollectionView, config: CollectionViewConfig<ItemType>) {
        self.items = []
        self.collectionView = collectionView
        self.config = config
        
        super.init()
        
        items.subscribeArray { [weak self] newItems, change in
            self?.applyChange(newItems, change: change)
        }
        .addTo(disposeBag)
        
        if let selections = config.selections {
            selections.subscribe { [weak self] in
                self?.syncSelectionsToModel()
            }
            .addTo(disposeBag)
        }
    }
    
    private func applyChange(newItems: [ItemType], change: ArrayChange<ItemType>) {
        if suppressChangeNotifications {
            return
        }
        
        self.items = newItems
        
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.reloadData()
        
        syncSelectionsToModel()
    }
    
    private func syncSelectionsToModel() {
        guard let collectionView = collectionView else {
            return
        }

        guard let configSelections = config.selections else {
            return
        }
        
        let currentSelections = Set(collectionView.indexPathsForSelectedItems() ?? [])
        let expectedSelections = Set(configSelections.value.map { (item: ItemType) -> NSIndexPath? in
            if let index = items.indexOf(item) {
                return NSIndexPath(forItem: index, inSection: 0)
            }
            else {
                return nil
            }
            }
            .flatMap { $0 })
        
        let toDeselect = currentSelections.subtract(expectedSelections)
        for indexPath in toDeselect {
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        }
        
        let toSelect = expectedSelections.subtract(currentSelections)
        for indexPath in toSelect {
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
    
    private func withoutChangeNotifications(@noescape block: Void -> Void) {
        suppressChangeNotifications = true
        block()
        suppressChangeNotifications = false
    }
    
    //MARK: -
    
    @objc func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(config.cellIdentifier, forIndexPath: indexPath)
        let item = items[indexPath.row]
        config.configureCell(item, cell)
        return cell
    }
    
    @objc func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.item]
        config.selections?.value.append(item)
    }
    
    @objc func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.item]
        if let index = config.selections?.value.indexOf(item) {
            config.selections?.value.removeAtIndex(index)
        }
    }
}
