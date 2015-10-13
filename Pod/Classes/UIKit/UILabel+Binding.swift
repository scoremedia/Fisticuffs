//
//  UILabel+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-13.
//
//

import UIKit


private var textKey = "text"

extension UILabel {
    
    var b_text: Observable<String>? {
        get {
            return getObservableFor("text")
        }
        set (value) {
            setObservableFor("text", observable: value) {
                [weak self] text in
                self?.text = text
            }
        }
    }
    
}
