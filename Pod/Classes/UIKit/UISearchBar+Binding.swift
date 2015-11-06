//
//  UISearchBar+Binding.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import Foundation

public extension UISearchBar {
    
    var b_text: BidirectionalBinding<String> {
        get {
            return get("b_text", orSet: {
                let delegate: SearchBarDelegate = get("b_delegate", orSet: { SearchBarDelegate() })
                self.delegate = delegate
                
                return BidirectionalBinding<String>(
                    getter: { [weak self] in self?.text ?? "" },
                    setter: { [weak self] value in self?.text = value }
                )
            })
        }
    }
}

private class SearchBarDelegate: NSObject, UISearchBarDelegate {
    
    @objc func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.b_text.pushChangeToObservable()
    }
    
}
