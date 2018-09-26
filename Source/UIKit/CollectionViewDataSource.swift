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

extension UICollectionView: DataSourceView {
    public typealias CellView = UICollectionViewCell
    
    public func insertCells(indexPaths: [IndexPath]) {
        insertItems(at: indexPaths)
    }
    
    public func deleteCells(indexPaths: [IndexPath]) {
        deleteItems(at: indexPaths)
    }
    
    public func batchUpdates(_ updates: @escaping () -> Void) {
        performBatchUpdates(updates, completion: nil)
    }
    
    
    public func indexPathsForSelections() -> [IndexPath]? {
        return indexPathsForSelectedItems
    }
    
    public func select(indexPath: IndexPath) {
        selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition())
    }
    
    public func deselect(indexPath: IndexPath) {
        deselectItem(at: indexPath, animated: false)
    }
    
    
    public func dequeueCell(reuseIdentifier: String, indexPath: IndexPath) -> UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
}


open class CollectionViewDataSource<Item: Equatable>: DataSource<Item, UICollectionView>, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public override init(subscribable: Subscribable<[Item]>, view: UICollectionView) {
        super.init(subscribable: subscribable, view: view)
    }
    
    //MARK: UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(section: section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellAtIndexPath(indexPath)
    }
    
    @available(iOS 9, *)
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return editable && allowsMoving
    }
    
    @available(iOS 9, *)
    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        move(source: sourceIndexPath, destination: destinationIndexPath)
    }
    
    //MARK: UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return canSelect(indexPath: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return canSelect(indexPath: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect(indexPath: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didDeselect(indexPath: indexPath)
    }
    
}
