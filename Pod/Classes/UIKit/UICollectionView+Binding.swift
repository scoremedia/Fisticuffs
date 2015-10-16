//
//  UICollectionView+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import UIKit

public extension UICollectionView {
    
    func b_configure<T: AnyObject>(items: Observable<[T]>, @noescape block: (CollectionViewConfig<T>) -> Void) {
        b_configure(ArrayAdapter.forObservable(items), block: block)
    }
    
    private func b_configure<T: AnyObject>(adapter: ArrayAdapter<T>, @noescape block: (CollectionViewConfig<T>) -> Void) {
        let config = CollectionViewConfig<T>()
        block(config)
        
        let delegate = CollectionViewDelegate(adapter: adapter, collectionView: self, config: config)
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

private class CollectionViewDelegate<T: AnyObject> : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    weak var collectionView: UICollectionView?
    var adapter: ArrayAdapter<T>
    let config: CollectionViewConfig<T>
    
    var suppressChangeNotifications = false
    let disposeBag = DisposableBag()
    
    
    init(adapter: ArrayAdapter<T>, collectionView: UICollectionView, config: CollectionViewConfig<T>) {
        self.adapter = adapter
        self.collectionView = collectionView
        self.config = config
        
        super.init()
        
        adapter.subscribe { [weak self] newItems, change in
            self?.applyChange(newItems, change: change)
        }
        .addTo(disposeBag)
        
        if let selections = config.selections {
            selections.subscribe { [weak self] _ in
                self?.syncSelectionsToModel()
            }
            .addTo(disposeBag)
        }
    }
    
    private func applyChange(newItems: [T], change: ArrayChange<T>) {
        if suppressChangeNotifications {
            return
        }
        
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
        
        let items = adapter.rawArray
        
        let currentSelections = Set(collectionView.indexPathsForSelectedItems() ?? [])
        let expectedSelections = Set(configSelections.value.map { (item: T) -> NSIndexPath? in
            if let index = items.indexOf({ $0 === item }) {
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
        return adapter.count
    }
    
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(config.cellIdentifier, forIndexPath: indexPath)
        let item = adapter[indexPath.row]
        config.configureCell(item, cell)
        return cell
    }
    
    @objc func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = adapter[indexPath.item]
        config.selections?.value.append(item)
    }
    
    @objc func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let item = adapter[indexPath.item]
        if let index = config.selections?.value.indexOf({ $0 === item }) {
            config.selections?.value.removeAtIndex(index)
        }
    }
}
