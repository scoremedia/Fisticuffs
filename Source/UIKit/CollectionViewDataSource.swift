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
    
    public func insertCells(indexPaths indexPaths: [NSIndexPath]) {
        insertItemsAtIndexPaths(indexPaths)
    }
    
    public func deleteCells(indexPaths indexPaths: [NSIndexPath]) {
        deleteItemsAtIndexPaths(indexPaths)
    }
    
    public func batchUpdates(updates: () -> Void) {
        performBatchUpdates(updates, completion: nil)
    }
    
    
    public func indexPathsForSelections() -> [NSIndexPath]? {
        return indexPathsForSelectedItems()
    }
    
    public func select(indexPath indexPath: NSIndexPath) {
        selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
    }
    
    public func deselect(indexPath indexPath: NSIndexPath) {
        deselectItemAtIndexPath(indexPath, animated: false)
    }
    
    
    public func dequeueCell(reuseIdentifier reuseIdentifier: String, indexPath: NSIndexPath) -> UICollectionViewCell {
        return dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    }
}


public class CollectionViewDataSource<Item: Equatable>: DataSource<Item, UICollectionView>, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public override init(subscribable: Subscribable<[Item]>, view: UICollectionView) {
        super.init(subscribable: subscribable, view: view)
    }
    
    //MARK: UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(section: section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellAtIndexPath(indexPath)
    }
    
    @available(iOS 9, *)
    public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return editable && allowsMoving
    }
    
    @available(iOS 9, *)
    public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        move(source: sourceIndexPath, destination: destinationIndexPath)
    }
    
    //MARK: UICollectionViewDelegate

    public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canSelect(indexPath: indexPath)
    }

    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canSelect(indexPath: indexPath)
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        didSelect(indexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        didDeselect(indexPath: indexPath)
    }
    
}
