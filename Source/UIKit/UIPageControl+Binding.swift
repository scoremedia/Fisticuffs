//
//  UIPageControl+Binding.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-19.
//  Copyright © 2015 theScore. All rights reserved.
//

public extension UIPageControl {
    
    var b_currentPage: BidirectionalBinding<Int> {
        get {
            return get("b_currentPage", orSet: {
                addTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
                let cleanup = DisposableBlock { [weak self] in
                    self?.removeTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
                }
                
                return BidirectionalBinding<Int>(
                    getter: { [weak self] in self?.currentPage ?? 0 },
                    setter: { [weak self] value in self?.currentPage = value },
                    extraCleanup: cleanup
                )
            })
        }
    }
    
    @objc private func b_valueChanged(sender: UITextField) {
        b_currentPage.pushChangeToObservable()
    }
    
    
    var b_numberOfPages: Binding<Int> {
        return get("b_numberOfPages", orSet: {
            return Binding<Int>(setter: { [weak self] value in
                self?.numberOfPages = value
            })
        })
    }
    
}

