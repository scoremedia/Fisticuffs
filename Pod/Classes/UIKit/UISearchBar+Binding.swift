//
//  UISearchBar+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import Foundation

public extension UISearchBar {
    
    var b_text: Observable<String>? {
        get {
            return getObservableFor("text")
        }
        set (value) {
            setObservableFor("text", observable: value) {
                [weak self] str in
                if self?.text != str {
                    self?.text = str
                }
            }
            
            let delegate: SearchBarDelegate = get("delegate", orSet: { SearchBarDelegate() })
            self.delegate = delegate
        }
    }
    
}

private class SearchBarDelegate: NSObject, UISearchBarDelegate {
    
    @objc func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.b_text?.value = searchText
    }
    
}
