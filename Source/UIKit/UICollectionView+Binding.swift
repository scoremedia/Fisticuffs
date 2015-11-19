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
            S.ValueType.Generator.Element: Equatable>(items: S, @noescape block: (CollectionViewDataSource<S>) -> Void) {

                let dataSource = CollectionViewDataSource(subscribable: items, view: self)
                block(dataSource)
                
                set("dataSource", value: dataSource as AnyObject)
                
                self.delegate = dataSource
                self.dataSource = dataSource
    }
    
}
