//
//  UICollectionView+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import UIKit

public extension UICollectionView {
    
    func b_configure<T>(items: ObservableArray<T>, @noescape block: (CollectionViewConfig<T>) -> Void) {
        b_configure(ArrayAdapter.forObservableArray(items), block: block)
    }
    
    func b_configure<T>(items: Observable<[T]>, @noescape block: (CollectionViewConfig<T>) -> Void) {
        b_configure(ArrayAdapter.forObservable(items), block: block)
    }
    
    private func b_configure<T>(adapter: ArrayAdapter<T>, @noescape block: (CollectionViewConfig<T>) -> Void) {
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
    
    public func usingCellIdentifier(cellIdentifier: String, configureCell: (T, UICollectionViewCell) -> Void) {
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell
    }
}

private class CollectionViewDelegate<T> : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
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
        
        adapter.subscribe { [weak self] _, change in
            self?.applyChange(change)
        }
        .addTo(disposeBag)
    }
    
    private func applyChange(change: ArrayChange<T>) {
        if suppressChangeNotifications {
            return
        }
        
        collectionView?.reloadData()
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
}
