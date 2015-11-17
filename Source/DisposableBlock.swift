//
//  DisposableBlock.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-02.
//
//

import Foundation

class DisposableBlock: NSObject, Disposable {
    var block: (() -> Void)?
    
    init(block: () -> Void) {
        self.block = block
    }
    
    internal func dispose() {
        block?()
    }
}
